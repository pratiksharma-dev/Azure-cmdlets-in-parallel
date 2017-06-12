# Azure-cmdlets-in-parallel
Sample code to illustrate use of Azure powershell cmdlets in paralllel

It's difficult to run powershell cmdlets in parallel using the usual start-job cmdlet at it runs under a different session and unable to run under the same context as the script.

This example illustrates runing the code in paralel using multithreading by utilizing powershell runspace functionality

Reference taken from:
https://blogs.msdn.microsoft.com/mast/2016/06/29/microsoft-azure-how-to-execute-a-synchronous-azure-powershell-cmdlet-multiple-times-at-once-using-a-single-powershell-session/ 