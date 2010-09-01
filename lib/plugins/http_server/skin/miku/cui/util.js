/*
 * utility functions.
 */

/**
 * true when user agent is ipad.
 * @return <boolean>
 */
var isTouch = function(){
   return navigator.userAgent.match(/iPad/i) != null
}

/**
 * initialize array.
 * @params <int> arrayt size.
 * @params <any> default vlaue.
 * @retrun <array>
 */
var array = function(size, defaultValue){
   return (new Array(size)).map(function(x){ return defaultValue});
}


/**
 * The split() method is used to split an array into an array of arrays, and returns the new array.
 * @params <array> base array.
 * @params <interger> split size.
 * @retrun <array>
 */
var split = function(xs, size){
	var r = [];
	for(var i=0; i<xs.length;i+=size){
		var tmp = [];
		for(var j=i;j<i+size;j++){
			if(xs.length == j) break;
			tmp.push(xs[j]);
		}
		r.push(tmp);
	}
	return r;
};


var List = function(xs){
	index = -1;
	this.next = function(){ 
		if (xs.length > (index + 1)) index += 1;
		return this;
	}

	this.get = function(){
		return xs[index];	
	}
}


HttpProxy = {"ajax":function(params){
        $.ajax({  
         url: params.url,  
         async: true,  
         cache: false,  
         error:params.error,
         success:params.success
         })
}}
