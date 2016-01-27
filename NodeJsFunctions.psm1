function Out-NodeJSStack {
  param(
    [Parameter(ValueFromPipeline)] $text)
  
  $text -replace "([^\\])\\n","`$1`n"
}