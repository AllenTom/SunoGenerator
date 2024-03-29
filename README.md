# SunoGenerator
a client for suno to use ai music generator

## Preview
<img src="./doc/app.jpg" width=200 />


## Login to suno ai

### for android and ios

use in app webview to login to suno ai,will read token and save

click login button to login

<img src="./doc/first.png" width=200 />

login to suno and click 
<img src="./doc/already_login.png" width=200 />


### for other platform

input cookie string to login

1. go to `https://app.suno.ai/`
2. login you account
3. open devtools,hit `F12` or `ctrl+shift+i`
4. refresh page
5. find request `https://clerk.suno.ai/v1/client?_clerk_js_version=4.70.5`
6. find `cookie` in request header

<img src="./doc/find_out_cookie.png" width=400 />

7. copy `cookie` string to input box

<img src="./doc/input_cookie.png" width=200 />

