# Git push retry script - retries up to 25 times for intermittent network
param(
    [int]$MaxRetries = 25,
    [int]$WaitSeconds = 5,
    [int]$TimeoutSeconds = 45
)

$repoPath = "c:\Users\SIT-12\Desktop\dev2\xiuxian-alchemy"
Set-Location $repoPath

for ($i = 1; $i -le $MaxRetries; $i++) {
    Write-Host "[Attempt $i/$MaxRetries] Pushing to origin main..."
    
    $job = Start-Job -ScriptBlock { 
        param($path)
        Set-Location $path
        git push origin main 2>&1
    } -ArgumentList $repoPath
    
    $completed = Wait-Job $job -Timeout $TimeoutSeconds
    
    if ($completed) {
        $output = Receive-Job $job
        $exitCode = $job.ChildJobs[0].ExitCode
        # git push writes success to stderr; check for "Everything up-to-date" or "new branch"
        if ($output -match "Everything up-to-date|new branch.*->" -and $exitCode -ne 0) {
            $exitCode = 0
        }
    } else {
        Stop-Job $job
        $output = "TIMEOUT after ${TimeoutSeconds}s"
        $exitCode = -1
    }
    
    Remove-Job $job -Force
    
    if ($exitCode -eq 0) {
        Write-Host "SUCCESS: Push completed on attempt $i!" -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Push failed (exit code $exitCode): $output" -ForegroundColor Yellow
    
    if ($i -lt $MaxRetries) {
        Write-Host "Waiting ${WaitSeconds}s before retry..." 
        Start-Sleep -Seconds $WaitSeconds
    }
}

Write-Host "FAILED: Could not push after $MaxRetries attempts." -ForegroundColor Red
exit 1
