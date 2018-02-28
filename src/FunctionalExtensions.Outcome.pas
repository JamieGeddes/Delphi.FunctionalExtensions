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

unit FunctionalExtensions.Outcome;

interface

type
  Outcome = record
  private
    _isSuccess: Boolean;

    _error: string;

    class var OkOutcome: Outcome;

    constructor Create(const isSuccess: Boolean;
                       const error:     string);

    function GetIsSuccess: Boolean;
    function GetIsFailure: Boolean;

    function GetError: string;

  public
    class constructor Create;

    class function Ok: Outcome; static;
    class function Fail(const error: string): Outcome; static;

    class function FirstFailureOrSuccess(const results: array of Outcome): Outcome; static;

    property IsSuccess: Boolean read GetIsSuccess;
    property IsFailure: Boolean read GetIsFailure;

    property Error: string read GetError;
  end;


  Outcome<T> = record
  private
    _value: T;

    _error: string;

    _failure: Boolean;

    function GetValue: T;
    function GetError: string;

    constructor Create(const isFailure: Boolean;
                       const value:     T;
                       const error:     string);

  public
    type TCallback = reference to function(value: T): T;

    function IsSuccess: Boolean;
    function IsFailure: Boolean;

    class function Ok(const value: T): Outcome<T>; static;
    class function Fail(const error: string): Outcome<T>; static;

    class operator Implicit(const value: Outcome<T>): Outcome;

    function OnSuccess(callback: TCallback): Outcome<T>;

    property Value: T read GetValue;

    property Error: string read GetError;
  end;

implementation

uses
  System.SysUtils;

{ Outcome }

class constructor Outcome.Create;
begin
  OkOutcome := Outcome.Create(true, string.Empty);
end;

constructor Outcome.Create(const isSuccess: Boolean;
                           const error:     string);
begin
  if(isSuccess and not error.IsNullOrWhiteSpace(error)) then raise Exception.Create('error string should not be set for success');

  _isSuccess := isSuccess;
  _error := error;
end;

class function Outcome.Ok: Outcome;
begin
  Result := OkOutcome;
end;

class function Outcome.Fail(const error: string): Outcome;
begin
  Result := Outcome.Create(false, error);
end;

function Outcome.GetIsSuccess: Boolean;
begin
  Result := _isSuccess;
end;

function Outcome.GetIsFailure: Boolean;
begin
  Result := not _isSuccess;
end;

function Outcome.GetError: string;
begin
  Result := _error;
end;

class function Outcome.FirstFailureOrSuccess(const results: array of Outcome): Outcome;
var
  index: Integer;
  resultObj: Outcome;
begin
  for Index := Low(results) to High(results) do
  begin
    resultObj := results[Index];
    if(resultObj.IsFailure) then
    begin
      Exit(Fail(resultObj.Error));
    end;
  end;

  Result := Ok;
end;


{ Outcome<T> }

constructor Outcome<T>.Create(const isFailure: Boolean;
                              const value:     T;
                              const error:     string);
begin
  if(IsSuccess) then
  begin
    if(not String.IsNullOrWhiteSpace(error)) then raise Exception.Create('There should be no error message for success.');
  end;

  _value := value;
  _error := error;
  _failure := isFailure;
end;

function Outcome<T>.IsSuccess: Boolean;
begin
  Result := not _failure;
end;

function Outcome<T>.IsFailure: Boolean;
begin
  Result := _failure;
end;

class function Outcome<T>.Ok(const value: T): Outcome<T>;
begin
  Result := Outcome<T>.Create(false, value, String.Empty);
end;

class function Outcome<T>.Fail(const error: string): Outcome<T>;
begin
  Result := Outcome<T>.Create(true, Default(T), error);
end;

function Outcome<T>.GetValue: T;
begin
  if(not IsSuccess) then raise Exception.Create('No value for failure');

  Result := _value;
end;

function Outcome<T>.GetError: string;
begin
  if(IsSuccess) then raise Exception.Create('No error message for success');

  Result := _error;
end;

class operator Outcome<T>.Implicit(const value: Outcome<T>): Outcome;
begin
  if(value.IsSuccess) then Result := Outcome.Ok
  else Result := Outcome.Fail(value.Error);
end;

function Outcome<T>.OnSuccess(callback: TCallback): Outcome<T>;
begin
    if( IsFailure) then
        Result:= Outcome<T>.Fail(Error)
    else
        Result:= Outcome<T>.Ok(callback( Value));
end;

end.

