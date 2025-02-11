Configuration MyDSCConfig 
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost
    {
        #Ensure IIS is installed
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        }

        # Ensure config.xml exists with predefined content
        File ConfigFile
        {
            DestinationPath = "C:\inetpub\wwwroot\config.xml"
            Ensure = "Present"
            Type = "File"
            Contents = "<configuration>My Config Content</configuration>"
        }

        # Ensure w3svc (IIS) service is running
        Service IISService
        {
            Name = "w3svc"
            State = "Running"
            StartUpType = "Automatic"
            Ensure = "Present"
        }
    }
}