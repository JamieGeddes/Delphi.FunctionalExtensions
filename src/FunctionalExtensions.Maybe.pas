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

unit FunctionalExtensions.Maybe;

interface


type
  Maybe<T: class> = record
  private
    _value: T;

    function GetValue: T;

    constructor Create(const value: T);

  public
    class operator Implicit(const value: T): Maybe<T>;

    function From(const obj: T): Maybe<T>;

    function HasValue: Boolean;
    function HasNoValue: Boolean;

    property Value: T read GetValue;
  end;

implementation

{ Maybe<T> }

class operator Maybe<T>.Implicit(const value: T): Maybe<T>;
begin
  Result := Maybe<T>.Create(value);
end;

constructor Maybe<T>.Create(const value: T);
begin
  _value := value;
end;

function Maybe<T>.From(const obj: T): Maybe<T>;
begin
  Result := Maybe<T>.Create(obj);
end;

function Maybe<T>.HasValue: Boolean;
begin
  Result := Assigned( _value);
end;

function Maybe<T>.HasNoValue: Boolean;
begin
  Result := not HasValue;
end;

function Maybe<T>.GetValue: T;
begin
  Result := _value;
end;

end.

