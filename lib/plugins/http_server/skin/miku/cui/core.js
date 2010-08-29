/**
 * Sprite Constracutor.
 */
var Sprite = function(){
   var obj = $("<img />").appendTo("#sprite");
   obj.css('position', 'absolute').css("buttom", 0);

   // regist dialog move behavor.
   obj.mousedown(function(e){
      obj
         .data("clickPointX" , e.pageX - obj.offset().left)
         .data("clickPointY" , e.pageY - obj.offset().top);
        
      $(document).mousemove(function(e){
         obj.css({
            top :e.pageY  - obj.data("clickPointY")+"px",
            left:e.pageX - obj.data("clickPointX")+"px"
         })
      })
   }).mouseup(function(){
      $(document).unbind("mousemove")
   })


   /**
    * proxy sprite image bind event.
    */
   this.bind = function(area, event_name, callback){
      var x = 0;
	   var y = 0;

		if(arguments.length == 2){
      	obj.bind(area, event_name);
			return;
		}

      obj.bind("touchmove",function(e){
	      x = event.touches[0].pageX;
         y = event.touches[0].pageY;
      });
      obj.bind("mousemove",function(e){
         x = e.pageX;
         y = e.pageY;
      });

      obj.bind(event_name, function(e){
			if(
		  		   (area["left"] <= x && x <= (area["left"] + area["width"]) )
			   && (area["top"]  <= y && y <= (area["top"]  + area["height"]) )
			){
			   callback(e);
			}
      });
   }


   /**
    * change sprite image.
    * @params<string> image file path.
    */
   this.image = function(path){
	   obj.attr("src", path);
	   return this;
   }

   /**
    * change sprite image for interval time.
    * @params<string> image file path.
    * @params<integer> millisecond.
    */
   this.motion = function(path, interval){
	   var current = obj.attr("src");
	   var self = this;
	   self.image(path);

	   setTimeout(function(){ self.image(current) } , interval);

      return self;
   }

   /**
    * touch action.
    */
   this.touch = function(area, args, callback){ this.bind(area, "click", callback) };

   /**
    * nadenade action.
    */
   this.nadenade = function(area, args, callback){ 
      var step = [true].concat(array(args.count, false));
      step.idx = 0;
      step.isDone = function(){ return step.reduce(function(r, x){return r && x}) };
      step.reset  = function(){
         for(var i=1;i<step.length;i++){
            step[i] = false;
         }
         step.idx = 0;
      }

      var isOverPoint = function(idx, x){
         var buf = 30;
         var left1 = area["left"];
         var left2 = left1 + buf;
         var right1 = left1 + area["width"] - buf;
         var right2 = right1 + buf;

         return (idx % 2 == 0) ? (step[idx] && left1  <= x && x <= left2)
                               : (step[idx] && right1 <= x && x <= right2)
      }

      var action = function(x){
         if (isOverPoint(step.idx, x)) {
            step.idx += 1;
            step[step.idx] = true;
         }

         if (step.isDone()) {
            callback();
            step.reset();
         }
      }

      if(isTouch()){
         this.bind(area, 'touchmove', function(e){
            action(event.touches[0].pageX);
         });
      }else{
         this.bind(area, 'mousemove', function(e){
            action(e.pageX);
         });
      }
   }
}
	

/**
 * Dialog Constructor.
 */
var Dialog = function(left, top, width, height, padding, bgcolor, textcolor, size){
   var dlg = $("<div class='dialog'/>").appendTo("#sprite");

   // setting default css.
   dlg.css("display", "none")
      .css("position", "absolute")
      .css("margin", 0)
      .css("padding", padding)
      .css("background-color", bgcolor)
      .css("color", textcolor);


   // regist dialog move behavor.
   dlg.mousedown(function(e){
      dlg
         .data("clickPointX" , e.pageX - dlg.offset().left)
         .data("clickPointY" , e.pageY - dlg.offset().top);
        
      $(document).mousemove(function(e){
         dlg.css({
            top :e.pageY  - dlg.data("clickPointY")+"px",
            left:e.pageX - dlg.data("clickPointX")+"px"
         })
      })
   }).mouseup(function(){
      $(document).unbind("mousemove")
   })

   /**
    * show dialog.
    * @param<string> message.
    * @param<integer> show interval.
    */
   this.show = function(msg, interval){ 
      dlg 
         .css("left",   left)
         .css("top",    top)
         .css("width",  width)
         .css("height", height)
         .css("font-size", size)
         .fadeIn("fast");

		dlg
			.empty()
			.append(msg);

		if(arguments.length >= 2){
       	setTimeout(function(){dlg.fadeOut("fast")} , interval);
		}
   };

	/**
	 * close dialog.
	 */
	this.close = function(){
   	dlg.fadeOut("fast");
	}
}


