ShapadoSocket = function() {
  var self=this, $config;
  function initialize() {
    WEB_SOCKET_SWF_LOCATION = "/javascripts/web-socket-js/WebSocketMain.swf";

    $config = $("#websocket");
    this.error_count = 0;
    this.ws = new WebSocket("ws://"+$config.data("host")+":34567/");
    this.socket_key = null;


    this.ws.onmessage = function(evt) {
      ShapadoSocket.parse(evt.data);
    };

    window.webSocketError = function(message) {
      console.error(decodeURIComponent(message));
      ShapadoSocket.error_count += 1;
    }

    this.ws.onclose = function() {
      if(ShapadoSocket.error_count < 3)
        setTimeout(ShapadoSocket.initialize, 5000)
    };

    this.ws.onopen = function() {
      ShapadoSocket.send({id: 'start', key: $config.data("key"), channel_id: $config.data("group")});
    };
  }

  function addChatMessage(from, message) {
    $("#chat_div").chatbox("option", "boxManager").addMsg(from, message);
  }

  function parse(data) {
    var data = JSON.parse(data);

    window.console && console.log("received: ");
    window.console && console.log(data);

    switch(data.id) {
      case 'chatmessage': {
        addChatMessage(data.from, data.message);
      }
      break;
      case 'newquestion': {
        ShapadoUI.newQuestion(data);
      }
      break;
      case 'updatequestion': {
        ShapadoUI.updateQuestion(data);
      }
      break;
      case 'destroyquestion': {
        ShapadoUI.deleteQuestion(data);
      }
      break;
      case 'newanswer': {
        ShapadoUI.newAnswer(data);
      }
      break;
      case 'updateanswer': {
        ShapadoUI.updateAnswer(data);
      }
      break;
      case 'vote': {
        ShapadoUI.vote(data);
      }
      break;
      case 'newcomment': {
        ShapadoUI.newComment(data);
      }
      break;
      case 'updatedcomment': {
        ShapadoUI.updateComment(data);
      }
      break;
      case 'newactivity': {
        ShapadoUI.newActivity(data);
      }
      break;
    }
  }

  function send(data) {
    this.ws.send(JSON.stringify(data))
  }

  return {
    initialize:initialize,
    addChatMessage:addChatMessage,
    parse:parse,
    send:send
  }
}();
