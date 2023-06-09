Set-PSReadLineKeyHandler -Key Tab -Function Complete
Enable-PowerType
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView

function Start-SSH
{
    ssh -A $args
}

oh-my-posh init pwsh --config ~/my-sys-setups/windows/common/oh-my-posh/oh-my-posh.json | Invoke-Expression