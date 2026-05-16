#requires -Version 5.1
# End-to-end smoke as a Hail user. Hits the exact RPCs the Flutter app uses.
# Anonymous JWT only; no service_role.

$ErrorActionPreference = 'Stop'
$url  = 'https://ulojulpdlleisymszamf.supabase.co'
$anon = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVsb2p1bHBkbGxlaXN5bXN6YW1mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4ODQxNDAsImV4cCI6MjA5NDQ2MDE0MH0.8advfSbwBxTsuuvk3-UKxCJ9eu4q6urd8KF5_8bBjys'

$hailLat   = 27.5219;  $hailLng   = 41.6907   # Hail
$riyadhLat = 24.7136;  $riyadhLng = 46.6753   # Riyadh (~640 km from Hail)

$tx = [ordered]@{}

function Step($name, $obj) {
  $tx[$name] = $obj
  $json = $obj | ConvertTo-Json -Depth 6 -Compress
  if ($json.Length -gt 240) { $json = $json.Substring(0,240) + '...' }
  Write-Host ("[{0}] {1}" -f $name, $json) -ForegroundColor Cyan
}

function Call-Sb($method, $path, $token, $body) {
  $h = @{
    apikey         = $anon
    Authorization  = "Bearer $token"
    'Content-Type' = 'application/json'
    Prefer         = 'return=representation'
  }
  $uri = "$url$path"
  if ($null -eq $body) {
    return Invoke-RestMethod -Method $method -Uri $uri -Headers $h
  } else {
    $payload = $body | ConvertTo-Json -Depth 6 -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
    return Invoke-RestMethod -Method $method -Uri $uri -Headers $h -Body $bytes
  }
}

Write-Host '== 1. anonymous sign-in ==' -ForegroundColor Yellow
$signup = Call-Sb 'POST' '/auth/v1/signup' $anon @{}
$token  = $signup.access_token
$uid    = $signup.user.id
Step 'sign_in' @{ user_id = $uid; has_token = ($null -ne $token) }

Write-Host '== 2. fetch own profile (numeric_id assigned server-side) ==' -ForegroundColor Yellow
$prof = Call-Sb 'GET' ("/rest/v1/profiles?id=eq.$uid" + '&select=numeric_id,created_at') $token $null
Step 'profile' $prof

Write-Host '== 3. set_my_location to Hail (100m snap) ==' -ForegroundColor Yellow
$setLoc = Call-Sb 'POST' '/rest/v1/rpc/set_my_location' $token @{ p_lat = $hailLat; p_lng = $hailLng }
Step 'set_my_location_hail' @{ result = $setLoc }

Write-Host '== 4. create a normal post in Hail ==' -ForegroundColor Yellow
$body1 = [char]0x0645+[char]0x0633+[char]0x0627+[char]0x0621+' Hail '+[char]0x0628+[char]0x062E+[char]0x064A+[char]0x0631
$newPostId = Call-Sb 'POST' '/rest/v1/rpc/create_post' $token @{
  p_body      = $body1
  p_tag       = $null
  p_proximity = 'city'
  p_lat       = $hailLat
  p_lng       = $hailLng
}
Step 'create_post' @{ id = $newPostId; body = $body1 }

Write-Host '== 5. create a SPAMMY post (10-digit phone) -> server should reject ==' -ForegroundColor Yellow
try {
  $bad = Call-Sb 'POST' '/rest/v1/rpc/create_post' $token @{
    p_body      = '0501234567 call me'
    p_tag       = $null
    p_proximity = 'city'
    p_lat       = $hailLat
    p_lng       = $hailLng
  }
  Step 'create_post_spam' @{ accepted = $true; id = $bad; verdict = 'FAIL_NOT_BLOCKED' }
} catch {
  Step 'create_post_spam' @{ blocked = $true; reason = $_.ErrorDetails.Message; verdict = 'OK_BLOCKED' }
}

Write-Host '== 6. posts_near (15km radius) sees own post ==' -ForegroundColor Yellow
$feed = Call-Sb 'POST' '/rest/v1/rpc/posts_near' $token @{
  p_lat = $hailLat; p_lng = $hailLng; p_radius_m = 15000; p_limit = 20
}
$mine = $feed | Where-Object { $_.id -eq $newPostId }
Step 'feed_near_hail' @{
  count       = ($feed | Measure-Object).Count
  mine_listed = ($null -ne $mine)
  my_dist_m   = ($mine | ForEach-Object { $_.distance_m })
}

Write-Host '== 7. vote +1 on the post ==' -ForegroundColor Yellow
$score1 = Call-Sb 'POST' '/rest/v1/rpc/cast_vote' $token @{
  p_target_type = 'post'; p_target_id = $newPostId; p_value = 1
}
Step 'vote_up' @{ new_score = $score1 }

Write-Host '== 8. comment on the post ==' -ForegroundColor Yellow
$commentId = Call-Sb 'POST' '/rest/v1/rpc/create_comment' $token @{
  p_post_id   = $newPostId
  p_parent_id = $null
  p_body      = 'first comment from terminal'
}
Step 'create_comment' @{ id = $commentId }

Write-Host '== 9. read comments via view comments_for_post ==' -ForegroundColor Yellow
$comments = Call-Sb 'GET' ("/rest/v1/comments_for_post?post_id=eq.$newPostId" + '&select=id,body,score,created_at') $token $null
Step 'fetch_comments' @{ count = ($comments | Measure-Object).Count; first = ($comments | Select-Object -First 1) }

Write-Host '== 10. update_my_post (owner edits own body) ==' -ForegroundColor Yellow
try {
  Call-Sb 'POST' '/rest/v1/rpc/update_my_post' $token @{ p_post_id = $newPostId; p_body = ($body1 + ' [edited]') } | Out-Null
  $post = Call-Sb 'GET' ("/rest/v1/posts_feed?id=eq.$newPostId" + '&select=id,body,edited_at') $token $null
  Step 'update_my_post' @{ post = $post; verdict = 'OK_EDITED' }
} catch {
  Step 'update_my_post' @{ error = $_.ErrorDetails.Message; verdict = 'FAIL' }
}

Write-Host '== 11. GEO ISOLATION: move to Riyadh, post must NOT appear ==' -ForegroundColor Yellow
Call-Sb 'POST' '/rest/v1/rpc/set_my_location' $token @{ p_lat = $riyadhLat; p_lng = $riyadhLng } | Out-Null
$feedR = Call-Sb 'POST' '/rest/v1/rpc/posts_near' $token @{
  p_lat = $riyadhLat; p_lng = $riyadhLng; p_radius_m = 15000; p_limit = 50
}
$mineR = $feedR | Where-Object { $_.id -eq $newPostId }
$verdict11 = if ($null -eq $mineR) { 'OK_ISOLATED' } else { 'FAIL_LEAK' }
Step 'feed_near_riyadh' @{
  count          = ($feedR | Measure-Object).Count
  hail_post_seen = ($null -ne $mineR)
  verdict        = $verdict11
}

Write-Host '== 12. back to Hail; try whispering to OWN post (must fail) ==' -ForegroundColor Yellow
Call-Sb 'POST' '/rest/v1/rpc/set_my_location' $token @{ p_lat = $hailLat; p_lng = $hailLng } | Out-Null
try {
  $chatId = Call-Sb 'POST' '/rest/v1/rpc/request_whisper' $token @{ p_post_id = $newPostId }
  Step 'whisper_self' @{ allowed = $true; chat_id = $chatId; verdict = 'FAIL_SELF_WHISPER_ALLOWED' }
} catch {
  Step 'whisper_self' @{ blocked = $true; reason = $_.ErrorDetails.Message; verdict = 'OK_BLOCKED' }
}

Write-Host '== 13. submit_feedback (bug report) ==' -ForegroundColor Yellow
try {
  $fb = Call-Sb 'POST' '/rest/v1/rpc/submit_feedback' $token @{
    p_subject = 'smoke test'; p_body = 'auto report from terminal'; p_locale = 'ar'; p_app_version = 'qa-1.0'
  }
  Step 'submit_feedback' @{ accepted = $true; id = $fb; verdict = 'OK' }
} catch {
  $emsg = if ($_.ErrorDetails) { $_.ErrorDetails.Message } else { $_.Exception.Message }
  Step 'submit_feedback' @{ error = $emsg; verdict = 'FAIL' }
}

Write-Host '== 14. delete_my_post (soft delete) ==' -ForegroundColor Yellow
Call-Sb 'POST' '/rest/v1/rpc/delete_my_post' $token @{ p_post_id = $newPostId } | Out-Null
$after = Call-Sb 'GET' ("/rest/v1/posts_feed?id=eq.$newPostId" + '&select=id') $token $null
$visible = (($after | Measure-Object).Count -gt 0)
$verdict14 = if ($visible) { 'FAIL_STILL_VISIBLE' } else { 'OK_HIDDEN' }
Step 'delete_my_post' @{ visible_after_delete = $visible; verdict = $verdict14 }

Write-Host ''
Write-Host '=== SUMMARY (JSON) ===' -ForegroundColor Green
$outPath = Join-Path $PSScriptRoot 'smoke_result.json'
($tx | ConvertTo-Json -Depth 8) | Out-File -Encoding utf8 -FilePath $outPath
Write-Host ("Wrote: " + $outPath)
