set COR_ENABLE_PROFILING=1
set COR_PROFILER={71DA0A04-7777-4EC6-9643-7D28B46A8A41}
set COR_PROFILER_PATH=%~dp0newrelic\NewRelic.Profiler.dll
set NEWRELIC_HOME=%~dp0newrelic
set NEWRELIC_INSTALL_PATH=%~dp0newrelic
set SystemDrive=C:

..\tmp\lifecycle\WebAppServer.exe
