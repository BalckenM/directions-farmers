@echo off
SET PATH=C:\flutter\bin;C:\Program Files\Git\bin;C:\Program Files\Git\cmd;%PATH%
cd /d "e:\4Directions'\Products\mobile_app"
echo Running tests... > test_output.txt
flutter test test/routing/poultry_hub_routing_test.dart --reporter=expanded >> test_output.txt 2>&1
echo Exit code: %ERRORLEVEL% >> test_output.txt
