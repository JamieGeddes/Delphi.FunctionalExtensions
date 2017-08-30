{
MIT License

Copyright (c) 2017 Jamie Geddes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
}
program Delphi.FunctionalExtensions.Tests;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.XML.NUnit,
  DUnitX.Test,
  DUnitX.TestFixture,
  DUnitX.TestFramework,
  DUnitX.TestResult,
  DUnitX.RunResults,
  DUnitX.TestRunner,
  DUnitX.Windows.Console,
  DUnitX.FixtureResult,
  DUnitX.Attributes,
  Maybe.Tests in 'Maybe.Tests.pas',
  Widget in 'Widget.pas',
  FunctionalExtensions.Maybe in '..\src\FunctionalExtensions.Maybe.pas',
  FunctionalExtensions.Option in '..\src\FunctionalExtensions.Option.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;

begin
  try
//    //Create the runner
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    //tell the runner how we will log things
    logger := TDUnitXConsoleLogger.Create(true);
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create;
    runner.AddLogger(logger);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;

    System.Write('Done.. press <Enter> key to quit.');
    System.Readln;
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
