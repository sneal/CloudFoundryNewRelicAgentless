# CloudFoundry New Relic Agentless Install Demo

This application includes the New Relic Azure Websites agent which also works in CloudFoundry
without requiring a New Relic Windows Agent be installed on the Windows cell. This application can push New Relic metrics from any CloudFoundry Windows cell without any other install steps required by an operations team.

## Execute Demo

1. Clone this repo and build the solution in VisualStudio 2015+
2. Edit the `newrelic/newrelic.config` and change the license key to your license.
3. `cf push` from the same directory as the manifest.yml.
4. Hit the pushed app in your browser
5. After a couple of minutes login to New Relic APM. You should now see the `CloudFoundry NewRelic Agentless` app listed.

## How to add New Relic to your CloudFoundry App

### Install NewRelic.Azure.WebSites.x64 Nuget Package

Open your web project in VisualStudio and install the [NewRelic.Azure.WebSites.x64](https://www.nuget.org/packages/NewRelic.Azure.WebSites.x64/) Nuget package. This will add a `newrelic` folder under the root of your website. Commit the newrelic folder to source control.

### Configure newrelic.config

Open the `newrelic/newrelic.config` file. Find the 'REPLACE_WITH_LICENSE_KEY' text and replace it with your New Relic license key.

```
<service licenseKey="REPLACE_WITH_LICENSE_KEY" ssl="true" />
```

Below the service element add an application element like so, changing the name element to the app name that should show up in New Relic.

```
  <application>
    <name>MyApp Name</name>
  </application>
```

Remove the directory attribute from the log element since it points to a folder your container doesn't have access too. It should look like this when you're done:

```
<log level="info" />
```

Now finally add an instrumentation element telling New Relic to profile the hwc.exe. This is the executable that bootstraps your PCF web app and we need to tell New Relic to profile it.

```
  <instrumentation>
    <applications>
      <application name="hwc.exe" />
    </applications>
  </instrumentation>
```

Save the updated New Relic.config file.

### newrelic subdirectory web.config

To ensure no one can download any files from the newrelic folder, add a _new_ web.config file in the newrelic folder with the following contents:

```
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <system.webServer>
    <security>
      <requestFiltering>
        <hiddenSegments>
          <add segment="newrelic"/>
        </hiddenSegments>
      </requestFiltering>
    </security>
  </system.webServer>
</configuration>
```

### Add Procfile

Now we need to add a file named `Procfile` to the root of the website. This file tells CloudFoundry to execute an alternative command on startup instead of the default hwc.exe. The Procfile needs one single line:

```
web: run.cmd
```

This tell CloudFoundry to execute the `run.cmd` batch file on startup, which we'll create next.

### Add run.cmd

Finally we need to add a file named `run.cmd` to the root of the website. This file is executed on app instance startup by CloudFoundry. This batch file sets some environment variables to enable .NET profiling and configure New Relic to run from your app's newrelic folder. Finally it starts the hwc.exe just like CloudFoundry would do by default.

```
set COR_ENABLE_PROFILING=1
set COR_PROFILER={71DA0A04-7777-4EC6-9643-7D28B46A8A41}
set COR_PROFILER_PATH=%~dp0newrelic\NewRelic.Profiler.dll
set NEWRELIC_HOME=%~dp0newrelic
set NEWRELIC_INSTALL_PATH=%~dp0newrelic

.cloudfoundry\hwc.exe
```

This sets three <a href="https://msdn.microsoft.com/en-us/library/ee471451(v=vs.100).aspx">.NET 'COR_' profiler environment variables</a> that .NET 4.x + use to enable profiling without needing access to the registry as was required in older versions of .NET.  The final two environment variables tell New Relic where its files and configuration are, which we're dynamically pointing to in the newrelic folder under the root of our app website.

### Push to CloudFoundry

With all those files in place you can now `cf push` your application to any CloudFoundry installation with a Windows cell. There's no need to manually install a machine wide MSI or any other nonsense. Hopefully in the future some of this manual setup will be automated and some of the configuration will also work with the [New Relic Service Broker](https://docs.pivotal.io/partners/newrelic/index.html).
