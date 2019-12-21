<!DOCTYPE html>
<html>
  <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <title>CHAT</title>
      <link rel="stylesheet" type="text/css" href="http://localhost/w3.css">
      <link rel="stylesheet" type="text/css" href="http://localhost/ChatClient.css">
      <script type="text/javascript" href="/chatVisibility.js"></script>
      <script type="text/javascript" href="/chatSocket.js"></script>
  </head>

  <body>
<blockquote>
<p>Do you see a pale green box with rounded
corners and a drop shadow against a white
background? If not, your browser isnt
handling the generated content correctly
(or maybe not at all).</p>
</blockquote>
    <!--%for i in 1 2 3; do%-->
      <div class="w3-card-4 w3-dark-grey">
        <h3>Welcome <b><%$name%></b></h3>
        <div class="w3-container">
          <%if [ "$sex" = "he" ]; then%>
            <img src="/img_he.png" alt="Avatar" style="width:5%">
	  <%else%>
            <img src="/img_she.png" alt="Avatar" style="width:5%">
	  <%fi%>
        </div>  
      </div>  
          <!-- chatBoard.html -->
          <div class="w3-row-padding" style="margin:0 -16px">
              <div class="w3-third">
                  <div style="height:100px" class="w3-card w3-container w3-yellow w3-margin-bottom"><p><%$name%></p></div>
              </div>
              <div class="w3-third">
                  <div style="height:100px" class="w3-card-2 w3-container w3-margin-bottom"><p>w3-card-2</p></div>
              </div>
              <div class="w3-third">
                  <div style="height:100px" class="w3-card-4 w3-container w3-yellow w3-margin-bottom"><p>w3-card-4</p></div>
              </div>
          </div>
          <!-- end chatBoard.html -->
          <div class=\"w3-card\" id=\"userList\">---Users---</div>
          <div class=\"w3-card\" id=\"chatBox\">------------------------------ Chat ------------------------------<br></div>
          <br style=\"clear:both;\"/>
          <form class=\"w3-card\" name=\"message\" action='javascript:onSendMessage(\""+user+"\")' id=\"chatmsg\">
            <input name=\"usermsg\" type=\"text\" id=\"usermsg\" size=\"100\"/>
            <input class=\"w3-button w3-green\" name=\"sendmsg\" type=\"submit\" id=\"sendmsg\" value=\"Send\"/>
            <button class=\"w3-button w3-red\" onclick=\"window.close()\">Close</button>
          </form>
    <!--%done%-->
  </body>
</html>
