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

unit FunctionalExtensions.Option;

interface

type
  Option = record
  private
    _isSuccess: Boolean;

    _error: string;

    class var OkOption: Option;

    constructor Create(const isSuccess: Boolean;
                       const error:     string);

    function GetIsSuccess: Boolean;
    function GetIsFailure: Boolean;

    function GetError: string;

  public
    class constructor Create;

    class function Ok: Option; static;
    class function Fail(const error: string): Option; static;

    class function FirstFailureOrSuccess(const results: array of Option): Option; static;

    property IsSuccess: Boolean read GetIsSuccess;
    property IsFailure: Boolean read GetIsFailure;

    property Error: string read GetError;
  end;


  Option<T> = record
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

    class function Ok(const value: T): Option<T>; static;
    class function Fail(const error: string): Option<T>; static;

    class operator Implicit(const value: Option<T>): Option;

    function OnSuccess(callback: TCallback): Option<T>;

    property Value: T read GetValue;

    property Error: string read GetError;
  end;

implementation

uses
  System.SysUtils;

{ Option }

class constructor Option.Create;
begin
  OkOption := Option.Create(true, string.Empty);
end;

constructor Option.Create(const isSuccess: Boolean;
                          const error:     string);
begin
  if(isSuccess and not error.IsNullOrWhiteSpace(error)) then raise Exception.Create('error string should not be set for success');
  if(not isSuccess) and (error.IsEmpty) then raise Exception.Create('error string must be specified for error cases');

  _isSuccess := isSuccess;
  _error := error;
end;

class function Option.Ok: Option;
begin
  Result := OkOption;
end;

class function Option.Fail(const error: string): Option;
begin
  Result := Option.Create(false, error);
end;

function Option.GetIsSuccess: Boolean;
begin
  Result := _isSuccess;
end;

function Option.GetIsFailure: Boolean;
begin
  Result := not _isSuccess;
end;

function Option.GetError: string;
begin
  Result := _error;
end;

class function Option.FirstFailureOrSuccess(const results: array of Option): Option;
var
  index: Integer;
  resultObj: Option;
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


{ Option<T> }

constructor Option<T>.Create(const isFailure: Boolean;
                             const value:     T;
                             const error:     string);
begin
  if(isFailure) then
  begin
    if(String.IsNullOrWhiteSpace(error)) then raise Exception.Create('There must be an error message for failure.');
  end
  else begin
    if(not String.IsNullOrWhiteSpace(error)) then raise Exception.Create('There should be no error message for success.');
  end;

  _value := value;
  _error := error;
  _failure := isFailure;
end;

function Option<T>.IsSuccess: Boolean;
begin
  Result := not _failure;
end;

function Option<T>.IsFailure: Boolean;
begin
  Result := _failure;
end;

class function Option<T>.Ok(const value: T): Option<T>;
begin
  Result := Option<T>.Create(false, value, String.Empty);
end;

class function Option<T>.Fail(const error: string): Option<T>;
begin
  Result := Option<T>.Create(true, Default(T), error);
end;

function Option<T>.GetValue: T;
begin
  if(not IsSuccess) then raise Exception.Create('No value for failure');

  Result := _value;
end;

function Option<T>.GetError: string;
begin
  if(IsSuccess) then raise Exception.Create('No error message for success');

  Result := _error;
end;

class operator Option<T>.Implicit(const value: Option<T>): Option;
begin
  if(value.IsSuccess) then Result := Option.Ok
  else Result := Option.Fail(value.Error);
end;

function Option<T>.OnSuccess(callback: TCallback): Option<T>;
begin
    if( IsFailure) then
        Result:= Option<T>.Fail(Error)
    else
        Result:= Option<T>.Ok(callback( Value));
end;

end.

