 #ws

javascript:
  $(function(){
    function wsjob_connect() {
      var url = "wss://" + location.host + "/job.ws";
  
      // Open WebSocket connection
      var ws = new WebSocket(url);
      console.log('Created WebSocket: ' + url);
  
      // Append each message
      ws.onmessage = function(e) {
        // {"topic":"compile","pct":12,"data":"crypto/subtle.cr: 2 passed"}
        var d = JSON.parse(e.data);
        console.log(d);
        var job = window['wsjob_' + d.topic];
        if (job && job.onmessage) {
          try { job.onmessage(d) } catch(e) { console.log(e); }
        }
      };
  
      window.onbeforeunload = function() {
        ws.onclose = function () {}; // disable onclose handler first
        ws.close();
        window.wsjob_connect = null;
      };
    };

    // execute once
    if (!window.wsjob_connect) {
      window.wsjob_connect = wsjob_connect;
      window.wsjob_connect();
    }
  
    // Attach ajax wsjob handler
    window.AJAX('a.wsjob');
  });
