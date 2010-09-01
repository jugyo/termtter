var INTERVAL = 1700;
//
// define image.
//
var 通常 = 'cui/chara/miku/images/001.png';
var 怒り = 'cui/chara/miku/images/004.png';
var 喜び = 'cui/chara/miku/images/003.png';

//
// define part.
//
var 頭 = {"left":180,  "top":40,  "width":100, "height":80};
var 胸 = {"left":160, "top":300, "width":120,  "height":60};

//
// define actions.
//
var アクション = [
   {"part":胸, "action":["touch"],                 "img":怒り, "msg":"Hなのはいけないと思います！"},
   {"part":頭, "action":["nadenade", {"count":5}], "img":喜び, "msg":"♪〜"}
];

$(function(){
   // initialize
   var sprite = new Sprite();
   sprite.dlg = new Dialog(390, 70, 200, 60, '20px', "#141414", "#98FF68", '24px');
   sprite.image(通常);

   // regist actions.
   アクション.map(function(action){ 
      sprite[action.action[0]](action.part, action.action[1], function(e){
         sprite.motion(action.img, INTERVAL);
         sprite.dlg.show(action.msg, INTERVAL);   
      });            
   });

	// regist main menu.
   sprite.bind("dblclick", function(){ 
		var dlg = new Dialog(390, 70, 270, 50, '20px', "#141414", "#98FF68", '24px');
var msg =  $('<div id="input_area">' + 
           '<div id="wrap">' +
           '  <form id="execute_command">' + 
           '    <span id="prompt">&gt; </span><input id="execute_text" type="text" size="20" autocomplete=off />' +
           '  </form>' + 
           '</div>' + 
           '<div id="loading" style="display: none;">...</div></div>');
 
		dlg.show(msg, INTERVAL * 5); 
      $("#execute_command").submit(function () {
         var command = $("#execute_text").val();
         $('<div class="status_line"/>').text('> ' + command).prependTo('#result');

         cmd_history.add(command);

         if (command.match(/^\s*$/)) {
            return false;
         }
         $("#execute_text").val('');
         $("#prompt").hide();
         execute_command(command);

         return false;
      })
	});
})

