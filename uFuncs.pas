unit uFuncs;

{
  Common functions
}

interface

function ProcessMaskEditString(const sIn: String): String;

implementation

function ProcessMaskEditString(const sIn: String): String;
var
  i: Integer;
begin
  Result:='0';
  for i:=1 to Length(sIn) do
    if sIn[i] <> ' ' then
      Result:=Result + sIn[i];

  i:=1;
  while (i <= Length(Result) - 1) and (Result[i]='0') do
    Inc(i);
  Delete(Result, 1, i - 1);
end;

end.
