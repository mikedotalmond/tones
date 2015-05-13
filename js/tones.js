(function (console) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = true;
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,__class__: EReg
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = function() { };
Lambda.__name__ = true;
Lambda.exists = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) return true;
	}
	return false;
};
Lambda.indexOf = function(it,v) {
	var i = 0;
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var v2 = $it0.next();
		if(v == v2) return i;
		i++;
	}
	return -1;
};
var List = function() {
	this.length = 0;
};
List.__name__ = true;
List.prototype = {
	add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,iterator: function() {
		return new _$List_ListIterator(this.h);
	}
	,__class__: List
};
var _$List_ListIterator = function(head) {
	this.head = head;
	this.val = null;
};
_$List_ListIterator.__name__ = true;
_$List_ListIterator.prototype = {
	hasNext: function() {
		return this.head != null;
	}
	,next: function() {
		this.val = this.head[0];
		this.head = this.head[1];
		return this.val;
	}
	,__class__: _$List_ListIterator
};
var Main = function() { };
Main.__name__ = true;
Main.main = function() {
	var h = window.document.location.search;
	switch(h) {
	case "?basic":
		var basic = new tones_examples_Basic();
		break;
	case "?releaseLater":
		var releaseLater = new tones_examples_ReleaseLater();
		break;
	case "?sharedContext":
		var sharedContext = new tones_examples_SharedContext();
		break;
	case "?customWaves":
		var customWaves = new tones_examples_CustomWaves();
		break;
	case "?sequence":
		var sequence = new tones_examples_Sequence();
		break;
	case "?polysynth":
		var polysynth = new tones_examples_KeyboardControlled();
		break;
	default:
		window.document.location.search = "?basic";
	}
};
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.compare = function(a,b) {
	return a == b?0:a > b?1:-1;
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
var haxe_Http = function(url) {
	this.url = url;
	this.headers = new List();
	this.params = new List();
	this.async = true;
};
haxe_Http.__name__ = true;
haxe_Http.prototype = {
	request: function(post) {
		var me = this;
		me.responseData = null;
		var r = this.req = js_Browser.createXMLHttpRequest();
		var onreadystatechange = function(_) {
			if(r.readyState != 4) return;
			var s = (function($this) {
				var $r;
				try {
					$r = r.status;
				} catch( e ) {
					if (e instanceof js__$Boot_HaxeError) e = e.val;
					$r = null;
				}
				return $r;
			}(this));
			if(s != null) {
				var protocol = window.location.protocol.toLowerCase();
				var rlocalProtocol = new EReg("^(?:about|app|app-storage|.+-extension|file|res|widget):$","");
				var isLocal = rlocalProtocol.match(protocol);
				if(isLocal) s = r.responseText != null?200:404;
			}
			if(s == undefined) s = null;
			if(s != null) me.onStatus(s);
			if(s != null && s >= 200 && s < 400) {
				me.req = null;
				me.onData(me.responseData = r.responseText);
			} else if(s == null) {
				me.req = null;
				me.onError("Failed to connect or resolve host");
			} else switch(s) {
			case 12029:
				me.req = null;
				me.onError("Failed to connect to host");
				break;
			case 12007:
				me.req = null;
				me.onError("Unknown host");
				break;
			default:
				me.req = null;
				me.responseData = r.responseText;
				me.onError("Http Error #" + r.status);
			}
		};
		if(this.async) r.onreadystatechange = onreadystatechange;
		var uri = this.postData;
		if(uri != null) post = true; else {
			var _g_head = this.params.h;
			var _g_val = null;
			while(_g_head != null) {
				var p = (function($this) {
					var $r;
					_g_val = _g_head[0];
					_g_head = _g_head[1];
					$r = _g_val;
					return $r;
				}(this));
				if(uri == null) uri = ""; else uri += "&";
				uri += encodeURIComponent(p.param) + "=" + encodeURIComponent(p.value);
			}
		}
		try {
			if(post) r.open("POST",this.url,this.async); else if(uri != null) {
				var question = this.url.split("?").length <= 1;
				r.open("GET",this.url + (question?"?":"&") + uri,this.async);
				uri = null;
			} else r.open("GET",this.url,this.async);
		} catch( e1 ) {
			if (e1 instanceof js__$Boot_HaxeError) e1 = e1.val;
			me.req = null;
			this.onError(e1.toString());
			return;
		}
		if(!Lambda.exists(this.headers,function(h) {
			return h.header == "Content-Type";
		}) && post && this.postData == null) r.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
		var _g_head1 = this.headers.h;
		var _g_val1 = null;
		while(_g_head1 != null) {
			var h1 = (function($this) {
				var $r;
				_g_val1 = _g_head1[0];
				_g_head1 = _g_head1[1];
				$r = _g_val1;
				return $r;
			}(this));
			r.setRequestHeader(h1.header,h1.value);
		}
		r.send(uri);
		if(!this.async) onreadystatechange(null);
	}
	,onData: function(data) {
	}
	,onError: function(msg) {
	}
	,onStatus: function(status) {
	}
	,__class__: haxe_Http
};
var haxe_Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe_Timer.__name__ = true;
haxe_Timer.delay = function(f,time_ms) {
	var t = new haxe_Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
};
haxe_Timer.stamp = function() {
	return new Date().getTime() / 1000;
};
haxe_Timer.prototype = {
	stop: function() {
		if(this.id == null) return;
		clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
	}
	,__class__: haxe_Timer
};
var haxe_ds_BalancedTree = function() {
};
haxe_ds_BalancedTree.__name__ = true;
haxe_ds_BalancedTree.prototype = {
	set: function(key,value) {
		this.root = this.setLoop(key,value,this.root);
	}
	,get: function(key) {
		var node = this.root;
		while(node != null) {
			var c = this.compare(key,node.key);
			if(c == 0) return node.value;
			if(c < 0) node = node.left; else node = node.right;
		}
		return null;
	}
	,iterator: function() {
		var ret = [];
		this.iteratorLoop(this.root,ret);
		return HxOverrides.iter(ret);
	}
	,setLoop: function(k,v,node) {
		if(node == null) return new haxe_ds_TreeNode(null,k,v,null);
		var c = this.compare(k,node.key);
		var tmp;
		if(c == 0) tmp = new haxe_ds_TreeNode(node.left,k,v,node.right,node == null?0:node._height); else if(c < 0) {
			var nl = this.setLoop(k,v,node.left);
			tmp = this.balance(nl,node.key,node.value,node.right);
		} else {
			var nr = this.setLoop(k,v,node.right);
			tmp = this.balance(node.left,node.key,node.value,nr);
		}
		return tmp;
	}
	,iteratorLoop: function(node,acc) {
		if(node != null) {
			this.iteratorLoop(node.left,acc);
			acc.push(node.value);
			this.iteratorLoop(node.right,acc);
		}
	}
	,balance: function(l,k,v,r) {
		var hl = l == null?0:l._height;
		var hr = r == null?0:r._height;
		var tmp;
		if(hl > hr + 2) {
			var tmp1;
			var _this = l.left;
			if(_this == null) tmp1 = 0; else tmp1 = _this._height;
			var tmp2;
			var _this1 = l.right;
			if(_this1 == null) tmp2 = 0; else tmp2 = _this1._height;
			if(tmp1 >= tmp2) tmp = new haxe_ds_TreeNode(l.left,l.key,l.value,new haxe_ds_TreeNode(l.right,k,v,r)); else tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l.left,l.key,l.value,l.right.left),l.right.key,l.right.value,new haxe_ds_TreeNode(l.right.right,k,v,r));
		} else if(hr > hl + 2) {
			var tmp3;
			var _this2 = r.right;
			if(_this2 == null) tmp3 = 0; else tmp3 = _this2._height;
			var tmp4;
			var _this3 = r.left;
			if(_this3 == null) tmp4 = 0; else tmp4 = _this3._height;
			if(tmp3 > tmp4) tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l,k,v,r.left),r.key,r.value,r.right); else tmp = new haxe_ds_TreeNode(new haxe_ds_TreeNode(l,k,v,r.left.left),r.left.key,r.left.value,new haxe_ds_TreeNode(r.left.right,r.key,r.value,r.right));
		} else tmp = new haxe_ds_TreeNode(l,k,v,r,(hl > hr?hl:hr) + 1);
		return tmp;
	}
	,compare: function(k1,k2) {
		return Reflect.compare(k1,k2);
	}
	,__class__: haxe_ds_BalancedTree
};
var haxe_ds_TreeNode = function(l,k,v,r,h) {
	if(h == null) h = -1;
	this.left = l;
	this.key = k;
	this.value = v;
	this.right = r;
	if(h == -1) {
		var tmp;
		var _this = this.left;
		if(_this == null) tmp = 0; else tmp = _this._height;
		var tmp1;
		var _this1 = this.right;
		if(_this1 == null) tmp1 = 0; else tmp1 = _this1._height;
		var tmp2;
		if(tmp > tmp1) {
			var _this2 = this.left;
			if(_this2 == null) tmp2 = 0; else tmp2 = _this2._height;
		} else {
			var _this3 = this.right;
			if(_this3 == null) tmp2 = 0; else tmp2 = _this3._height;
		}
		this._height = tmp2 + 1;
	} else this._height = h;
};
haxe_ds_TreeNode.__name__ = true;
haxe_ds_TreeNode.prototype = {
	__class__: haxe_ds_TreeNode
};
var haxe_ds_IntMap = function() {
	this.h = { };
};
haxe_ds_IntMap.__name__ = true;
haxe_ds_IntMap.__interfaces__ = [haxe_IMap];
haxe_ds_IntMap.prototype = {
	remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe_ds_IntMap
};
var haxe_ds_ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
haxe_ds_ObjectMap.__name__ = true;
haxe_ds_ObjectMap.__interfaces__ = [haxe_IMap];
haxe_ds_ObjectMap.prototype = {
	set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe_ds_ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,remove: function(key) {
		var id = key.__id__;
		if(this.h.__keys__[id] == null) return false;
		delete(this.h[id]);
		delete(this.h.__keys__[id]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h.__keys__ ) {
		if(this.h.hasOwnProperty(key)) a.push(this.h.__keys__[key]);
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i.__id__];
		}};
	}
	,__class__: haxe_ds_ObjectMap
};
var hxsignal_ConnectionTimes = { __ename__ : true, __constructs__ : ["Once","Times","Forever"] };
hxsignal_ConnectionTimes.Once = ["Once",0];
hxsignal_ConnectionTimes.Once.toString = $estr;
hxsignal_ConnectionTimes.Once.__enum__ = hxsignal_ConnectionTimes;
hxsignal_ConnectionTimes.Times = function(t) { var $x = ["Times",1,t]; $x.__enum__ = hxsignal_ConnectionTimes; $x.toString = $estr; return $x; };
hxsignal_ConnectionTimes.Forever = ["Forever",2];
hxsignal_ConnectionTimes.Forever.toString = $estr;
hxsignal_ConnectionTimes.Forever.__enum__ = hxsignal_ConnectionTimes;
var hxsignal_ConnectPosition = { __ename__ : true, __constructs__ : ["AtBack","AtFront"] };
hxsignal_ConnectPosition.AtBack = ["AtBack",0];
hxsignal_ConnectPosition.AtBack.toString = $estr;
hxsignal_ConnectPosition.AtBack.__enum__ = hxsignal_ConnectPosition;
hxsignal_ConnectPosition.AtFront = ["AtFront",1];
hxsignal_ConnectPosition.AtFront.toString = $estr;
hxsignal_ConnectPosition.AtFront.__enum__ = hxsignal_ConnectPosition;
var hxsignal_ds_LinkedList = function() {
	List.call(this);
};
hxsignal_ds_LinkedList.__name__ = true;
hxsignal_ds_LinkedList.__super__ = List;
hxsignal_ds_LinkedList.prototype = $extend(List.prototype,{
	__class__: hxsignal_ds_LinkedList
});
var hxsignal_ds_TreeMap = function() {
	haxe_ds_BalancedTree.call(this);
};
hxsignal_ds_TreeMap.__name__ = true;
hxsignal_ds_TreeMap.__super__ = haxe_ds_BalancedTree;
hxsignal_ds_TreeMap.prototype = $extend(haxe_ds_BalancedTree.prototype,{
	firstKey: function() {
		var first = this.getFirstNode();
		return first != null?first.key:null;
	}
	,lastKey: function() {
		var last = this.getLastNode();
		return last != null?last.key:null;
	}
	,firstValue: function() {
		var first = this.getFirstNode();
		return first != null?first.value:null;
	}
	,lastValue: function() {
		var last = this.getLastNode();
		return last != null?last.value:null;
	}
	,getFirstNode: function() {
		var n = this.root;
		if(n != null) while(n.left != null) n = n.left;
		return n;
	}
	,getLastNode: function() {
		var n = this.root;
		if(n != null) while(n.right != null) n = n.right;
		return n;
	}
	,__class__: hxsignal_ds_TreeMap
});
var hxsignal_impl_Connection = function(signal,slot,times) {
	this.signal = signal;
	if(slot == null) throw new js__$Boot_HaxeError("Slot cannot be null");
	this.slot = slot;
	this.times = times;
	this.blocked = false;
	this.connected = true;
};
hxsignal_impl_Connection.__name__ = true;
hxsignal_impl_Connection.prototype = {
	__class__: hxsignal_impl_Connection
};
var hxsignal_impl_SignalBase = function() {
	this.slots = new hxsignal_impl_SlotMap();
};
hxsignal_impl_SignalBase.__name__ = true;
hxsignal_impl_SignalBase.prototype = {
	connect: function(slot,times,groupId,at) {
		if(times == null) times = hxsignal_ConnectionTimes.Forever;
		if(!this.updateConnection(slot,times)) {
			var conn = new hxsignal_impl_Connection(this,slot,times);
			this.slots.insert(conn,groupId,at);
		}
	}
	,updateConnection: function(slot,times,groupId,at) {
		var con = this.slots.get(slot);
		if(con == null) return false;
		if(groupId != null && con.groupId != groupId || at != null) {
			this.slots.disconnect(slot);
			return false;
		}
		con.times = times;
		con.calledTimes = 0;
		con.connected = true;
		return true;
	}
	,loop: function(delegate) {
		this.emitting = true;
		var $it0 = this.slots.groups.iterator();
		while( $it0.hasNext() ) {
			var g = $it0.next();
			var _g_head = g.h;
			var _g_val = null;
			while(_g_head != null) {
				var tmp;
				_g_val = _g_head[0];
				_g_head = _g_head[1];
				tmp = _g_val;
				var con = tmp;
				if(con.connected && !con.blocked) {
					con.calledTimes++;
					delegate(con);
					if(!con.connected) this.slots.disconnect(con.slot);
					if(con.times == hxsignal_ConnectionTimes.Once) con.times = hxsignal_ConnectionTimes.Times(1);
					{
						var _g = con.times;
						switch(_g[1]) {
						case 1:
							if(_g[2] <= con.calledTimes) this.slots.disconnect(con.slot);
							break;
						default:
						}
					}
				}
			}
		}
		this.emitting = false;
	}
	,__class__: hxsignal_impl_SignalBase
};
var hxsignal_impl_Signal0 = function() {
	hxsignal_impl_SignalBase.call(this);
};
hxsignal_impl_Signal0.__name__ = true;
hxsignal_impl_Signal0.__super__ = hxsignal_impl_SignalBase;
hxsignal_impl_Signal0.prototype = $extend(hxsignal_impl_SignalBase.prototype,{
	emit: function() {
		var delegate = function(con) {
			con.slot();
		};
		this.loop(delegate);
	}
	,__class__: hxsignal_impl_Signal0
});
var hxsignal_impl_Signal1 = function() {
	hxsignal_impl_SignalBase.call(this);
};
hxsignal_impl_Signal1.__name__ = true;
hxsignal_impl_Signal1.__super__ = hxsignal_impl_SignalBase;
hxsignal_impl_Signal1.prototype = $extend(hxsignal_impl_SignalBase.prototype,{
	emit: function(p1) {
		var delegate = function(con) {
			con.slot(p1);
		};
		this.loop(delegate);
	}
	,__class__: hxsignal_impl_Signal1
});
var hxsignal_impl_Signal2 = function() {
	hxsignal_impl_SignalBase.call(this);
};
hxsignal_impl_Signal2.__name__ = true;
hxsignal_impl_Signal2.__super__ = hxsignal_impl_SignalBase;
hxsignal_impl_Signal2.prototype = $extend(hxsignal_impl_SignalBase.prototype,{
	emit: function(p1,p2) {
		var delegate = function(con) {
			con.slot(p1,p2);
		};
		this.loop(delegate);
	}
	,__class__: hxsignal_impl_Signal2
});
var hxsignal_impl_SlotMap = function() {
	this.clear();
};
hxsignal_impl_SlotMap.__name__ = true;
hxsignal_impl_SlotMap.prototype = {
	clear: function() {
		this.slots = new haxe_ds_ObjectMap();
		this.groups = new hxsignal_ds_TreeMap();
		this.groups.set(0,new hxsignal_ds_LinkedList());
	}
	,insert: function(con,groupId,at) {
		if(at == null) at = hxsignal_ConnectPosition.AtBack;
		this.slots.set(con.slot,con);
		var group;
		if(groupId == null) {
			if(at != null) switch(at[1]) {
			case 1:
				groupId = this.groups.firstKey();
				group = this.groups.firstValue();
				break;
			default:
				groupId = this.groups.lastKey();
				group = this.groups.lastValue();
			} else {
				groupId = this.groups.lastKey();
				group = this.groups.lastValue();
			}
		} else {
			group = this.groups.get(groupId);
			if(group == null) {
				group = new hxsignal_ds_LinkedList();
				this.groups.set(groupId,group);
			}
		}
		con.groupId = groupId;
		if(at != null) switch(at[1]) {
		case 1:
			group.push(con);
			break;
		default:
			group.add(con);
		} else group.add(con);
	}
	,get: function(slot) {
		return this.slots.h[slot.__id__];
	}
	,disconnect: function(slot) {
		var con = this.slots.h[slot.__id__];
		if(con == null) return false;
		this.slots.remove(slot);
		con.connected = false;
		return true;
	}
	,__class__: hxsignal_impl_SlotMap
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__cast = function(o,t) {
	if(js_Boot.__instanceof(o,t)) return o; else throw new js__$Boot_HaxeError("Cannot cast " + Std.string(o) + " to " + Std.string(t));
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return (Function("return typeof " + name + " != \"undefined\" ? " + name + " : null"))();
};
var js_Browser = function() { };
js_Browser.__name__ = true;
js_Browser.createXMLHttpRequest = function() {
	if(typeof XMLHttpRequest != "undefined") return new XMLHttpRequest();
	if(typeof ActiveXObject != "undefined") return new ActiveXObject("Microsoft.XMLHTTP");
	throw new js__$Boot_HaxeError("Unable to create XMLHttpRequest object.");
};
var tones_OscillatorTypeShim = function() { };
tones_OscillatorTypeShim.__name__ = true;
var tones_Tones = function(audioContext,destinationNode) {
	this.ID = 0;
	this.customWave = null;
	if(audioContext == null) this.context = tones_Tones.createContext(); else this.context = audioContext;
	if(destinationNode == null) this.destination = this.context.destination; else this.destination = destinationNode;
	this.polyphony = 0;
	this.activeNotes = new haxe_ds_IntMap();
	this.toneBegin = new hxsignal_impl_Signal2();
	this.toneEnd = new hxsignal_impl_Signal2();
	this.releaseFudge = window.navigator.userAgent.indexOf("Firefox") > -1?4096 / this.context.sampleRate:0;
	this.type = window.OscillatorTypeShim.SINE;
	this.set_attack(10.0);
	this.set_release(100.0);
	this.set_volume(.1);
};
tones_Tones.__name__ = true;
tones_Tones.createContext = function() {
	return new (window.AudioContext || window.webkitAudioContext)();
};
tones_Tones.prototype = {
	playFrequency: function(freq,delayBy,autoRelease) {
		if(autoRelease == null) autoRelease = true;
		if(delayBy == null) delayBy = .0;
		var id = this.ID;
		this.ID++;
		var attackSeconds = this._attack / 1000;
		var envelope = this.context.createGain();
		var triggerTime = this.context.currentTime + delayBy;
		var releaseTime = triggerTime + attackSeconds;
		envelope.gain.value = 0;
		envelope.connect(this.destination);
		envelope.gain.setTargetAtTime(this._volume,triggerTime,Math.log(attackSeconds + 1.0) / 4.605170185988092);
		var osc = this.context.createOscillator();
		if(this.type == window.OscillatorTypeShim.CUSTOM) osc.setPeriodicWave(this.customWave); else osc.type = this.type;
		osc.frequency.value = freq;
		osc.connect(envelope);
		osc.start(triggerTime);
		this.activeNotes.h[id] = { id : id, osc : osc, env : envelope, release : this._release, attackEnd : triggerTime + attackSeconds};
		var delayMillis = Math.floor(delayBy * 1000);
		if(delayMillis == 0) this.triggerToneBegin(id); else {
			var tmp;
			var f = $bind(this,this.triggerToneBegin);
			var id1 = id;
			tmp = function() {
				f(id1);
			};
			haxe_Timer.delay(tmp,delayMillis);
		}
		if(autoRelease) {
			envelope.gain.setTargetAtTime(0,releaseTime,Math.log(this._release / 1000 + 1.0) / 4.605170185988092);
			var tmp1;
			var f1 = $bind(this,this.stop);
			var id2 = id;
			tmp1 = function() {
				f1(id2);
			};
			haxe_Timer.delay(tmp1,Math.round(delayBy * 1000 + this._attack + this._release));
		}
		return id;
	}
	,triggerToneBegin: function(id) {
		this.polyphony++;
		this.toneBegin.emit(id,this.polyphony);
		console.log("On | Polyphony:" + this.polyphony + ", noteId:" + id);
	}
	,play: function(playData) {
		this.set_volume(playData.volume);
		this.set_attack(playData.attack);
		this.set_release(playData.release);
		this.type = playData.type;
		return this.playFrequency(playData.freq,playData.delay == null?0:playData.delay);
	}
	,releaseNote: function(id) {
		var note = this.activeNotes.h[id];
		if(note == null) return;
		var t = this.context.currentTime + this.releaseFudge;
		var r = note.release;
		if(note.attackEnd > this.context.currentTime) note.env.gain.cancelScheduledValues(t);
		note.env.gain.setTargetAtTime(0,t,Math.log(r / 1000 + 1.0) / 4.605170185988092);
		var tmp;
		var f = $bind(this,this.stop);
		var id1 = id;
		tmp = function() {
			f(id1);
		};
		haxe_Timer.delay(tmp,Math.round(r));
	}
	,releaseAll: function() {
		var $it0 = this.activeNotes.keys();
		while( $it0.hasNext() ) {
			var id = $it0.next();
			this.releaseNote(id);
		}
	}
	,stop: function(id) {
		var note = this.activeNotes.h[id];
		if(note == null) return;
		note.osc.stop(this.context.currentTime);
		note.osc.disconnect();
		note.env.gain.cancelScheduledValues(this.context.currentTime);
		note.env.disconnect();
		this.activeNotes.remove(id);
		this.polyphony--;
		this.toneEnd.emit(id,this.polyphony);
		console.log("Off | Polyphony:" + this.polyphony + ", noteId:" + id);
	}
	,set_attack: function(value) {
		if(value < 1) value = 1;
		return this._attack = value;
	}
	,set_release: function(value) {
		if(value < 1) value = 1;
		return this._release = value;
	}
	,set_volume: function(value) {
		if(value < 0) value = 0; else if(value > 1) value = 1;
		return this._volume = value;
	}
	,__class__: tones_Tones
};
var tones_examples_Basic = function() {
	this.tones = new tones_Tones();
	this.tones.playFrequency(440);
	this.tones.set_volume(.05);
	this.tones.set_attack(500);
	var freqUtil = new tones_utils_NoteFrequencyUtil();
	this.tones.playFrequency(freqUtil.noteNameToFrequency("C3"));
	this.tones.play({ freq : 280, volume : .1, attack : 250, release : 250, type : window.OscillatorTypeShim.SAWTOOTH});
};
tones_examples_Basic.__name__ = true;
tones_examples_Basic.prototype = {
	__class__: tones_examples_Basic
};
var tones_examples_CustomWaves = function() {
	this.mouseIsDown = false;
	this.lastTime = 0;
	var _g = this;
	var tmp;
	var _this = window.document;
	tmp = _this.createElement("p");
	var p = tmp;
	p.className = "noselect";
	p.textContent = "Mousedown and move the cursor. Press any key to select a new random wavetable. Check the dev console for some stats.";
	window.document.body.appendChild(p);
	window.document.addEventListener("keydown",function(e) {
		var tmp1;
		var x = Math.random() * _g.wavetables.data.length;
		tmp1 = x | 0;
		var i = tmp1;
		_g.setWave(i);
	});
	this.tones = new tones_Tones();
	this.tones.set_volume(.15);
	this.tones.set_attack(10);
	this.tones.set_release(500);
	this.tones.type = window.OscillatorTypeShim.CUSTOM;
	this.wavetables = new tones_utils_Wavetables();
	this.wavetables.loadComplete.connect($bind(this,this.wavetablesLoaded),hxsignal_ConnectionTimes.Once);
};
tones_examples_CustomWaves.__name__ = true;
tones_examples_CustomWaves.prototype = {
	wavetablesLoaded: function() {
		console.log(tones_utils_Wavetables.FileNames);
		console.log(this.wavetables.data);
		var tmp;
		var x = Math.random() * this.wavetables.data.length;
		tmp = x | 0;
		var i = tmp;
		this.setWave(i);
		window.document.addEventListener("mousedown",$bind(this,this.onMouse));
		window.document.addEventListener("mouseup",$bind(this,this.onMouse));
		window.document.addEventListener("mousemove",$bind(this,this.onMouse));
	}
	,setWave: function(index) {
		var data = this.wavetables.data[index];
		console.log("set wavetable to " + data.name);
		this.tones.customWave = this.tones.context.createPeriodicWave(data.real,data.imag);
	}
	,onMouse: function(e) {
		var _g = e.type;
		switch(_g) {
		case "mousedown":
			this.mouseIsDown = true;
			break;
		case "mouseup":
			this.mouseIsDown = false;
			break;
		case "mousemove":
			if(this.mouseIsDown) {
				var now = haxe_Timer.stamp();
				var dt = now - this.lastTime;
				if(dt > .05) {
					this.lastTime = now;
					this.tones.set_volume(e.clientY / window.innerHeight * .2);
					var f = 50 + 750 * (e.clientX / window.innerWidth);
					f = f < 20?20:f;
					this.tones.playFrequency(f);
					this.tones.playFrequency(tones_utils_NoteFrequencyUtil.detuneFreq(f * 2,(Math.random() - .5) * 50));
				}
			}
			break;
		}
	}
	,__class__: tones_examples_CustomWaves
};
var tones_examples_KeyboardControlled = function() {
	var tmp;
	var _this = window.document;
	tmp = _this.createElement("p");
	var p = tmp;
	p.className = "noselect";
	p.textContent = "Play using your keyboard. Check the dev console for some stats.";
	window.document.body.appendChild(p);
	this.context = tones_Tones.createContext();
	this.outGain = this.context.createGain();
	this.outGain.gain.value = .5;
	this.tonesA = new tones_Tones(this.context,this.outGain);
	this.tonesA.type = window.OscillatorTypeShim.SQUARE;
	this.tonesA.set_volume(.62);
	this.tonesA.set_attack(1);
	this.tonesA.set_release(2000);
	this.tonesB = new tones_Tones(this.context,this.outGain);
	this.tonesB.type = window.OscillatorTypeShim.SQUARE;
	this.tonesB.set_volume(.48);
	this.tonesB.set_attack(2000);
	this.tonesB.set_release(133);
	this.outGain.connect(this.context.destination);
	this.setupKeyboardControls();
	this.allWaveNames = ["Sine","Square","Sawtooth","Triangle"];
	this.wavetables = new tones_utils_Wavetables();
	this.wavetables.loadComplete.connect($bind(this,this.wavetablesLoaded),hxsignal_ConnectionTimes.Once);
};
tones_examples_KeyboardControlled.__name__ = true;
tones_examples_KeyboardControlled.prototype = {
	wavetablesLoaded: function() {
		var tmp;
		var _g = [];
		var _g1 = 0;
		var _g2 = this.wavetables.data;
		while(_g1 < _g2.length) {
			var item = _g2[_g1];
			++_g1;
			_g.push(item.name);
		}
		tmp = _g;
		this.allWaveNames = this.allWaveNames.concat(tmp);
		this.setupUI();
	}
	,setupUI: function() {
		var _g = this;
		this.gui = new dat.gui.GUI();
		this.gui.add({ volume : .5},"volume",0,1).step(0.00390625).onChange(function(_) {
			_g.outGain.gain.setValueAtTime(_,_g.context.currentTime + .1);
		});
		this.gui.add(this.keyboardInput,"octaveShift",-1,3).step(1).onChange($bind(this,this.releaseAll));
		var folder;
		var folder2;
		var tmp;
		var f = $bind(this,this.randomise);
		tmp = function() {
			f(-1,"all");
		};
		this.gui.add({ 'Randomise all' : tmp},"Randomise all");
		folder = this.gui.addFolder("Osc A");
		folder2 = folder.addFolder("Randomise");
		folder.add(this.tonesA,"_volume",0,1).step(0.00390625).listen();
		folder.add(this.tonesA,"_attack",1,2000).step(0.00390625).listen();
		folder.add(this.tonesA,"_release",1,2000).step(0.00390625).listen();
		var tmp1;
		var f1 = $bind(this,this.onWaveformSelect);
		var a2 = this.tonesA;
		tmp1 = function(a1) {
			f1(a1,a2);
		};
		folder.add({ waveform : "Square"},"waveform",this.allWaveNames).onChange(tmp1);
		folder.open();
		var tmp2;
		var f2 = $bind(this,this.randomise);
		tmp2 = function() {
			f2(0,"all");
		};
		folder2.add({ 'all' : tmp2},"all");
		var tmp3;
		var f3 = $bind(this,this.selectRandomOsc);
		tmp3 = function() {
			f3(0);
		};
		folder2.add({ 'type' : tmp3},"type");
		var tmp4;
		var f4 = $bind(this,this.randomise);
		tmp4 = function() {
			f4(0,"volume");
		};
		folder2.add({ 'volume' : tmp4},"volume");
		var tmp5;
		var f5 = $bind(this,this.randomise);
		tmp5 = function() {
			f5(0,"attack");
		};
		folder2.add({ 'attack' : tmp5},"attack");
		var tmp6;
		var f6 = $bind(this,this.randomise);
		tmp6 = function() {
			f6(0,"release");
		};
		folder2.add({ 'release' : tmp6},"release");
		folder = this.gui.addFolder("Osc B");
		folder2 = folder.addFolder("Randomise");
		folder.add(this.tonesB,"_volume",0,1).step(0.00390625).listen();
		folder.add(this.tonesB,"_attack",1,2000).step(0.00390625).listen();
		folder.add(this.tonesB,"_release",1,2000).step(0.00390625).listen();
		var tmp7;
		var f7 = $bind(this,this.onWaveformSelect);
		var a21 = this.tonesB;
		tmp7 = function(a11) {
			f7(a11,a21);
		};
		folder.add({ waveform : "Square"},"waveform",this.allWaveNames).onChange(tmp7);
		folder.open();
		var tmp8;
		var f8 = $bind(this,this.randomise);
		tmp8 = function() {
			f8(1,"all");
		};
		folder2.add({ 'all' : tmp8},"all");
		var tmp9;
		var f9 = $bind(this,this.selectRandomOsc);
		tmp9 = function() {
			f9(1);
		};
		folder2.add({ 'type' : tmp9},"type");
		var tmp10;
		var f10 = $bind(this,this.randomise);
		tmp10 = function() {
			f10(1,"volume");
		};
		folder2.add({ 'volume' : tmp10},"volume");
		var tmp11;
		var f11 = $bind(this,this.randomise);
		tmp11 = function() {
			f11(1,"attack");
		};
		folder2.add({ 'attack' : tmp11},"attack");
		var tmp12;
		var f12 = $bind(this,this.randomise);
		tmp12 = function() {
			f12(1,"release");
		};
		folder2.add({ 'release' : tmp12},"release");
	}
	,releaseAll: function() {
		this.tonesA.releaseAll();
		this.tonesB.releaseAll();
	}
	,randomise: function(tIndex,type) {
		var t = tIndex == 0?this.tonesA:this.tonesB;
		this.releaseAll();
		switch(type) {
		case "volume":
			t.set_volume(.01 + Math.random());
			break;
		case "attack":
			t.set_attack(Math.random() * 2000);
			break;
		case "release":
			t.set_release(Math.random() * 2000);
			break;
		case "all":
			if(tIndex == -1) {
				this.randomise(0,type);
				this.randomise(1,type);
			} else {
				this.selectRandomOsc(tIndex);
				this.randomise(tIndex,"volume");
				this.randomise(tIndex,"attack");
				this.randomise(tIndex,"release");
			}
			break;
		}
	}
	,selectRandomOsc: function(index) {
		var selects = window.document.querySelectorAll("select");
		var tmp;
		var x = Math.random() * this.allWaveNames.length;
		tmp = x | 0;
		var i = tmp;
		this.onWaveformSelect(this.allWaveNames[i],index == 0?this.tonesA:this.tonesB);
		(js_Boot.__cast(selects.item(index) , HTMLSelectElement)).selectedIndex = i;
	}
	,onWaveformSelect: function(value,target) {
		switch(value) {
		case "Sine":
			target.type = window.OscillatorTypeShim.SINE;
			break;
		case "Square":
			target.type = window.OscillatorTypeShim.SQUARE;
			break;
		case "Sawtooth":
			target.type = window.OscillatorTypeShim.SAWTOOTH;
			break;
		case "Triangle":
			target.type = window.OscillatorTypeShim.TRIANGLE;
			break;
		default:
			var data = this.getWavetableDataByName(value);
			target.type = window.OscillatorTypeShim.CUSTOM;
			target.customWave = this.context.createPeriodicWave(data.real,data.imag);
		}
		console.log("Oscillator set to " + value);
	}
	,getWavetableDataByName: function(value) {
		var _g = 0;
		var _g1 = this.wavetables.data;
		while(_g < _g1.length) {
			var item = _g1[_g];
			++_g;
			if(item.name == value) return item;
		}
		return null;
	}
	,setupKeyboardControls: function() {
		this.keyboardNotes = new tones_utils_KeyboardNotes(0);
		this.keyboardInput = new tones_utils_KeyboardInput(this.keyboardNotes);
		this.noteIndexToId = new haxe_ds_IntMap();
		this.activeKeys = [];
		var _g = 0;
		while(_g < 256) {
			var i = _g++;
			this.activeKeys[i] = false;
		}
		this.keyboardInput.octaveShift = 1;
		window.addEventListener("keydown",$bind(this,this.onKeyDown));
		window.addEventListener("keyup",$bind(this,this.onKeyUp));
		this.keyboardInput.noteOn.connect($bind(this,this.handleNoteOn));
		this.keyboardInput.noteOff.connect($bind(this,this.handleNoteOff));
	}
	,onKeyDown: function(e) {
		if(!this.activeKeys[e.keyCode]) {
			this.activeKeys[e.keyCode] = true;
			this.keyboardInput.onQwertyKeyDown(e.keyCode);
		}
	}
	,onKeyUp: function(e) {
		if(this.activeKeys[e.keyCode]) {
			this.activeKeys[e.keyCode] = false;
			this.keyboardInput.onQwertyKeyUp(e.keyCode);
		}
	}
	,handleNoteOn: function(index,volume) {
		var f = index >= 0 && index < 128?this.keyboardNotes.noteFreq.noteFrequencies[index]:NaN;
		var f2 = tones_utils_NoteFrequencyUtil.detuneFreq(f,(Math.random() - .5) * 25);
		var t = 1 / f;
		var phaseShift = t * (1 / (Math.random() * 6));
		var value = this.tonesA.playFrequency(f,0,false);
		this.noteIndexToId.h[index] = value;
		var value1 = this.tonesB.playFrequency(f2,phaseShift,false);
		this.noteIndexToId.h[index] = value1;
		console.log("note on:" + (index >= 0 && index < 128?this.keyboardNotes.noteFreq.noteNames[index]:null));
	}
	,handleNoteOff: function(index) {
		this.tonesA.releaseNote(this.noteIndexToId.h[index]);
		this.tonesB.releaseNote(this.noteIndexToId.h[index]);
		this.noteIndexToId.remove(index);
		console.log("note off:" + (index >= 0 && index < 128?this.keyboardNotes.noteFreq.noteNames[index]:null));
	}
	,__class__: tones_examples_KeyboardControlled
};
var tones_examples_ReleaseLater = function() {
	var tones2 = new tones_Tones();
	tones2.type = window.OscillatorTypeShim.SAWTOOTH;
	tones2.set_volume(.2);
	tones2.set_attack(200);
	tones2.set_release(2500);
	var noteId = tones2.playFrequency(540,.1,false);
	haxe_Timer.delay(function() {
		tones2.releaseNote(noteId);
	},2500);
};
tones_examples_ReleaseLater.__name__ = true;
tones_examples_ReleaseLater.prototype = {
	__class__: tones_examples_ReleaseLater
};
var tones_examples_Sequence = function() {
	this.tones = new tones_Tones();
	this.tones.set_volume(.1);
	this.tones.set_attack(25);
	this.tones.set_release(1000);
	this.tones.type = window.OscillatorTypeShim.SAWTOOTH;
	var freqUtil = new tones_utils_NoteFrequencyUtil();
	this.tones.playFrequency(freqUtil.noteNameToFrequency("C3"),0);
	this.tones.playFrequency(freqUtil.noteNameToFrequency("C4"),.2);
	this.tones.playFrequency(freqUtil.noteNameToFrequency("C5"),.4);
	this.tones.playFrequency(freqUtil.noteNameToFrequency("G3"),.8);
	this.tones.playFrequency(freqUtil.noteNameToFrequency("G4"),1);
	this.tones.playFrequency(freqUtil.noteNameToFrequency("G5"),1.2);
	this.tones.playFrequency(freqUtil.noteNameToFrequency("G2"),1);
	this.tones.playFrequency(freqUtil.noteNameToFrequency("G1"),1.2);
};
tones_examples_Sequence.__name__ = true;
tones_examples_Sequence.prototype = {
	__class__: tones_examples_Sequence
};
var tones_examples_SharedContext = function() {
	this.context = tones_Tones.createContext();
	var pan1 = this.context.createPanner();
	var pan2 = this.context.createPanner();
	pan1.panningModel = "equalpower";
	pan2.panningModel = "equalpower";
	this.setPan(.5,pan1);
	this.setPan(-.5,pan2);
	var masterVolume = this.context.createGain();
	masterVolume.gain.value = .5;
	masterVolume.connect(this.context.destination);
	pan1.connect(masterVolume);
	pan2.connect(masterVolume);
	var tones1 = new tones_Tones(this.context,pan1);
	var tones2 = new tones_Tones(this.context,pan2);
	tones1.type = window.OscillatorTypeShim.SAWTOOTH;
	tones1.set_volume(.2);
	tones1.set_attack(1);
	tones1.set_release(2500);
	tones2.type = window.OscillatorTypeShim.SQUARE;
	tones2.set_volume(.2);
	tones2.set_attack(500);
	tones2.set_release(1500);
	tones1.playFrequency(220,.5);
	tones2.playFrequency(110,1);
};
tones_examples_SharedContext.__name__ = true;
tones_examples_SharedContext.prototype = {
	setPan: function(value,node) {
		if(value == null) value = 0;
		var x = value * Math.PI / 2;
		var z = x + Math.PI / 2;
		if(z > Math.PI / 2) z = Math.PI - z;
		node.setPosition(Math.sin(x),0,Math.sin(z));
	}
	,__class__: tones_examples_SharedContext
};
var tones_utils_KeyboardInput = function(keyNotes) {
	this.octaveShift = 0;
	this.heldNotes = [];
	this.noteOn = new hxsignal_impl_Signal2();
	this.noteOff = new hxsignal_impl_Signal1();
	this.keyToNote = keyNotes.keycodeToNoteIndex;
};
tones_utils_KeyboardInput.__name__ = true;
tones_utils_KeyboardInput.prototype = {
	onQwertyKeyDown: function(code) {
		if(this.keyToNote.h.hasOwnProperty(code)) {
			var tmp;
			var noteIndex = this.keyToNote.h[code];
			tmp = noteIndex + this.octaveShift * 12;
			this.onNoteKeyDown(tmp);
		}
	}
	,onQwertyKeyUp: function(code) {
		if(this.heldNotes.length > 0 && this.keyToNote.h.hasOwnProperty(code)) {
			var tmp;
			var noteIndex = this.keyToNote.h[code];
			tmp = noteIndex + this.octaveShift * 12;
			this.onNoteKeyUp(tmp);
		}
	}
	,onNoteKeyDown: function(noteIndex,velocity) {
		if(velocity == null) velocity = .1;
		var i = Lambda.indexOf(this.heldNotes,noteIndex);
		if(i == -1) {
			this.heldNotes.push(noteIndex);
			this.noteOn.emit(noteIndex,velocity);
		}
	}
	,onNoteKeyUp: function(noteIndex) {
		var i = Lambda.indexOf(this.heldNotes,noteIndex);
		if(i != -1) this.noteOff.emit(this.heldNotes.splice(i,1)[0]);
	}
	,__class__: tones_utils_KeyboardInput
};
var tones_utils_KeyboardNotes = function(startOctave) {
	if(startOctave == null) startOctave = 0;
	this.startOctave = startOctave;
	this.noteFreq = new tones_utils_NoteFrequencyUtil();
	this.keycodeToNoteFreq = new haxe_ds_IntMap();
	this.keycodeToNoteIndex = new haxe_ds_IntMap();
	var value = this.noteFreq.noteNameToIndex("C" + startOctave);
	this.keycodeToNoteIndex.h[90] = value;
	var value1 = this.noteFreq.noteNameToIndex("C#" + startOctave);
	this.keycodeToNoteIndex.h[83] = value1;
	var value2 = this.noteFreq.noteNameToIndex("D" + startOctave);
	this.keycodeToNoteIndex.h[88] = value2;
	var value3 = this.noteFreq.noteNameToIndex("D#" + startOctave);
	this.keycodeToNoteIndex.h[68] = value3;
	var value4 = this.noteFreq.noteNameToIndex("E" + startOctave);
	this.keycodeToNoteIndex.h[67] = value4;
	var value5 = this.noteFreq.noteNameToIndex("F" + startOctave);
	this.keycodeToNoteIndex.h[86] = value5;
	var value6 = this.noteFreq.noteNameToIndex("F#" + startOctave);
	this.keycodeToNoteIndex.h[71] = value6;
	var value7 = this.noteFreq.noteNameToIndex("G" + startOctave);
	this.keycodeToNoteIndex.h[66] = value7;
	var value8 = this.noteFreq.noteNameToIndex("G#" + startOctave);
	this.keycodeToNoteIndex.h[72] = value8;
	var value9 = this.noteFreq.noteNameToIndex("A" + startOctave);
	this.keycodeToNoteIndex.h[78] = value9;
	var value10 = this.noteFreq.noteNameToIndex("A#" + startOctave);
	this.keycodeToNoteIndex.h[74] = value10;
	var value11 = this.noteFreq.noteNameToIndex("B" + startOctave);
	this.keycodeToNoteIndex.h[77] = value11;
	var value12 = this.noteFreq.noteNameToIndex("C" + (startOctave + 1));
	this.keycodeToNoteIndex.h[81] = value12;
	var value13 = this.noteFreq.noteNameToIndex("C#" + (startOctave + 1));
	this.keycodeToNoteIndex.h[50] = value13;
	var value14 = this.noteFreq.noteNameToIndex("D" + (startOctave + 1));
	this.keycodeToNoteIndex.h[87] = value14;
	var value15 = this.noteFreq.noteNameToIndex("D#" + (startOctave + 1));
	this.keycodeToNoteIndex.h[51] = value15;
	var value16 = this.noteFreq.noteNameToIndex("E" + (startOctave + 1));
	this.keycodeToNoteIndex.h[69] = value16;
	var value17 = this.noteFreq.noteNameToIndex("F" + (startOctave + 1));
	this.keycodeToNoteIndex.h[82] = value17;
	var value18 = this.noteFreq.noteNameToIndex("F#" + (startOctave + 1));
	this.keycodeToNoteIndex.h[53] = value18;
	var value19 = this.noteFreq.noteNameToIndex("G" + (startOctave + 1));
	this.keycodeToNoteIndex.h[84] = value19;
	var value20 = this.noteFreq.noteNameToIndex("G#" + (startOctave + 1));
	this.keycodeToNoteIndex.h[54] = value20;
	var value21 = this.noteFreq.noteNameToIndex("A" + (startOctave + 1));
	this.keycodeToNoteIndex.h[89] = value21;
	var value22 = this.noteFreq.noteNameToIndex("A#" + (startOctave + 1));
	this.keycodeToNoteIndex.h[55] = value22;
	var value23 = this.noteFreq.noteNameToIndex("B" + (startOctave + 1));
	this.keycodeToNoteIndex.h[85] = value23;
	var value24 = this.noteFreq.noteNameToIndex("C" + (startOctave + 2));
	this.keycodeToNoteIndex.h[73] = value24;
	var value25 = this.noteFreq.noteNameToIndex("C#" + (startOctave + 2));
	this.keycodeToNoteIndex.h[57] = value25;
	var value26 = this.noteFreq.noteNameToIndex("D" + (startOctave + 2));
	this.keycodeToNoteIndex.h[79] = value26;
	var value27 = this.noteFreq.noteNameToIndex("D#" + (startOctave + 2));
	this.keycodeToNoteIndex.h[48] = value27;
	var value28 = this.noteFreq.noteNameToIndex("E" + (startOctave + 2));
	this.keycodeToNoteIndex.h[80] = value28;
	var value29 = this.noteFreq.noteNameToIndex("F" + (startOctave + 2));
	this.keycodeToNoteIndex.h[219] = value29;
	var value30 = this.noteFreq.noteNameToIndex("F#" + (startOctave + 2));
	this.keycodeToNoteIndex.h[187] = value30;
	var value31 = this.noteFreq.noteNameToIndex("G" + (startOctave + 2));
	this.keycodeToNoteIndex.h[221] = value31;
	var tmp;
	var index = this.keycodeToNoteIndex.h[90];
	if(index >= 0 && index < 128) tmp = this.noteFreq.noteFrequencies[index]; else tmp = NaN;
	var value32 = tmp;
	this.keycodeToNoteFreq.h[90] = value32;
	var tmp1;
	var index1 = this.keycodeToNoteIndex.h[83];
	if(index1 >= 0 && index1 < 128) tmp1 = this.noteFreq.noteFrequencies[index1]; else tmp1 = NaN;
	var value33 = tmp1;
	this.keycodeToNoteFreq.h[83] = value33;
	var tmp2;
	var index2 = this.keycodeToNoteIndex.h[88];
	if(index2 >= 0 && index2 < 128) tmp2 = this.noteFreq.noteFrequencies[index2]; else tmp2 = NaN;
	var value34 = tmp2;
	this.keycodeToNoteFreq.h[88] = value34;
	var tmp3;
	var index3 = this.keycodeToNoteIndex.h[68];
	if(index3 >= 0 && index3 < 128) tmp3 = this.noteFreq.noteFrequencies[index3]; else tmp3 = NaN;
	var value35 = tmp3;
	this.keycodeToNoteFreq.h[68] = value35;
	var tmp4;
	var index4 = this.keycodeToNoteIndex.h[67];
	if(index4 >= 0 && index4 < 128) tmp4 = this.noteFreq.noteFrequencies[index4]; else tmp4 = NaN;
	var value36 = tmp4;
	this.keycodeToNoteFreq.h[67] = value36;
	var tmp5;
	var index5 = this.keycodeToNoteIndex.h[86];
	if(index5 >= 0 && index5 < 128) tmp5 = this.noteFreq.noteFrequencies[index5]; else tmp5 = NaN;
	var value37 = tmp5;
	this.keycodeToNoteFreq.h[86] = value37;
	var tmp6;
	var index6 = this.keycodeToNoteIndex.h[71];
	if(index6 >= 0 && index6 < 128) tmp6 = this.noteFreq.noteFrequencies[index6]; else tmp6 = NaN;
	var value38 = tmp6;
	this.keycodeToNoteFreq.h[71] = value38;
	var tmp7;
	var index7 = this.keycodeToNoteIndex.h[66];
	if(index7 >= 0 && index7 < 128) tmp7 = this.noteFreq.noteFrequencies[index7]; else tmp7 = NaN;
	var value39 = tmp7;
	this.keycodeToNoteFreq.h[66] = value39;
	var tmp8;
	var index8 = this.keycodeToNoteIndex.h[72];
	if(index8 >= 0 && index8 < 128) tmp8 = this.noteFreq.noteFrequencies[index8]; else tmp8 = NaN;
	var value40 = tmp8;
	this.keycodeToNoteFreq.h[72] = value40;
	var tmp9;
	var index9 = this.keycodeToNoteIndex.h[78];
	if(index9 >= 0 && index9 < 128) tmp9 = this.noteFreq.noteFrequencies[index9]; else tmp9 = NaN;
	var value41 = tmp9;
	this.keycodeToNoteFreq.h[78] = value41;
	var tmp10;
	var index10 = this.keycodeToNoteIndex.h[74];
	if(index10 >= 0 && index10 < 128) tmp10 = this.noteFreq.noteFrequencies[index10]; else tmp10 = NaN;
	var value42 = tmp10;
	this.keycodeToNoteFreq.h[74] = value42;
	var tmp11;
	var index11 = this.keycodeToNoteIndex.h[77];
	if(index11 >= 0 && index11 < 128) tmp11 = this.noteFreq.noteFrequencies[index11]; else tmp11 = NaN;
	var value43 = tmp11;
	this.keycodeToNoteFreq.h[77] = value43;
	var tmp12;
	var index12 = this.keycodeToNoteIndex.h[81];
	if(index12 >= 0 && index12 < 128) tmp12 = this.noteFreq.noteFrequencies[index12]; else tmp12 = NaN;
	var value44 = tmp12;
	this.keycodeToNoteFreq.h[81] = value44;
	var tmp13;
	var index13 = this.keycodeToNoteIndex.h[50];
	if(index13 >= 0 && index13 < 128) tmp13 = this.noteFreq.noteFrequencies[index13]; else tmp13 = NaN;
	var value45 = tmp13;
	this.keycodeToNoteFreq.h[50] = value45;
	var tmp14;
	var index14 = this.keycodeToNoteIndex.h[87];
	if(index14 >= 0 && index14 < 128) tmp14 = this.noteFreq.noteFrequencies[index14]; else tmp14 = NaN;
	var value46 = tmp14;
	this.keycodeToNoteFreq.h[87] = value46;
	var tmp15;
	var index15 = this.keycodeToNoteIndex.h[51];
	if(index15 >= 0 && index15 < 128) tmp15 = this.noteFreq.noteFrequencies[index15]; else tmp15 = NaN;
	var value47 = tmp15;
	this.keycodeToNoteFreq.h[51] = value47;
	var tmp16;
	var index16 = this.keycodeToNoteIndex.h[69];
	if(index16 >= 0 && index16 < 128) tmp16 = this.noteFreq.noteFrequencies[index16]; else tmp16 = NaN;
	var value48 = tmp16;
	this.keycodeToNoteFreq.h[69] = value48;
	var tmp17;
	var index17 = this.keycodeToNoteIndex.h[82];
	if(index17 >= 0 && index17 < 128) tmp17 = this.noteFreq.noteFrequencies[index17]; else tmp17 = NaN;
	var value49 = tmp17;
	this.keycodeToNoteFreq.h[82] = value49;
	var tmp18;
	var index18 = this.keycodeToNoteIndex.h[53];
	if(index18 >= 0 && index18 < 128) tmp18 = this.noteFreq.noteFrequencies[index18]; else tmp18 = NaN;
	var value50 = tmp18;
	this.keycodeToNoteFreq.h[53] = value50;
	var tmp19;
	var index19 = this.keycodeToNoteIndex.h[84];
	if(index19 >= 0 && index19 < 128) tmp19 = this.noteFreq.noteFrequencies[index19]; else tmp19 = NaN;
	var value51 = tmp19;
	this.keycodeToNoteFreq.h[84] = value51;
	var tmp20;
	var index20 = this.keycodeToNoteIndex.h[54];
	if(index20 >= 0 && index20 < 128) tmp20 = this.noteFreq.noteFrequencies[index20]; else tmp20 = NaN;
	var value52 = tmp20;
	this.keycodeToNoteFreq.h[54] = value52;
	var tmp21;
	var index21 = this.keycodeToNoteIndex.h[89];
	if(index21 >= 0 && index21 < 128) tmp21 = this.noteFreq.noteFrequencies[index21]; else tmp21 = NaN;
	var value53 = tmp21;
	this.keycodeToNoteFreq.h[89] = value53;
	var tmp22;
	var index22 = this.keycodeToNoteIndex.h[55];
	if(index22 >= 0 && index22 < 128) tmp22 = this.noteFreq.noteFrequencies[index22]; else tmp22 = NaN;
	var value54 = tmp22;
	this.keycodeToNoteFreq.h[55] = value54;
	var tmp23;
	var index23 = this.keycodeToNoteIndex.h[85];
	if(index23 >= 0 && index23 < 128) tmp23 = this.noteFreq.noteFrequencies[index23]; else tmp23 = NaN;
	var value55 = tmp23;
	this.keycodeToNoteFreq.h[85] = value55;
	var tmp24;
	var index24 = this.keycodeToNoteIndex.h[73];
	if(index24 >= 0 && index24 < 128) tmp24 = this.noteFreq.noteFrequencies[index24]; else tmp24 = NaN;
	var value56 = tmp24;
	this.keycodeToNoteFreq.h[73] = value56;
	var tmp25;
	var index25 = this.keycodeToNoteIndex.h[57];
	if(index25 >= 0 && index25 < 128) tmp25 = this.noteFreq.noteFrequencies[index25]; else tmp25 = NaN;
	var value57 = tmp25;
	this.keycodeToNoteFreq.h[57] = value57;
	var tmp26;
	var index26 = this.keycodeToNoteIndex.h[79];
	if(index26 >= 0 && index26 < 128) tmp26 = this.noteFreq.noteFrequencies[index26]; else tmp26 = NaN;
	var value58 = tmp26;
	this.keycodeToNoteFreq.h[79] = value58;
	var tmp27;
	var index27 = this.keycodeToNoteIndex.h[48];
	if(index27 >= 0 && index27 < 128) tmp27 = this.noteFreq.noteFrequencies[index27]; else tmp27 = NaN;
	var value59 = tmp27;
	this.keycodeToNoteFreq.h[48] = value59;
	var tmp28;
	var index28 = this.keycodeToNoteIndex.h[80];
	if(index28 >= 0 && index28 < 128) tmp28 = this.noteFreq.noteFrequencies[index28]; else tmp28 = NaN;
	var value60 = tmp28;
	this.keycodeToNoteFreq.h[80] = value60;
	var tmp29;
	var index29 = this.keycodeToNoteIndex.h[219];
	if(index29 >= 0 && index29 < 128) tmp29 = this.noteFreq.noteFrequencies[index29]; else tmp29 = NaN;
	var value61 = tmp29;
	this.keycodeToNoteFreq.h[219] = value61;
	var tmp30;
	var index30 = this.keycodeToNoteIndex.h[187];
	if(index30 >= 0 && index30 < 128) tmp30 = this.noteFreq.noteFrequencies[index30]; else tmp30 = NaN;
	var value62 = tmp30;
	this.keycodeToNoteFreq.h[187] = value62;
	var tmp31;
	var index31 = this.keycodeToNoteIndex.h[221];
	if(index31 >= 0 && index31 < 128) tmp31 = this.noteFreq.noteFrequencies[index31]; else tmp31 = NaN;
	var value63 = tmp31;
	this.keycodeToNoteFreq.h[221] = value63;
};
tones_utils_KeyboardNotes.__name__ = true;
tones_utils_KeyboardNotes.prototype = {
	__class__: tones_utils_KeyboardNotes
};
var tones_utils_NoteFrequencyUtil = function() {
	if(tones_utils_NoteFrequencyUtil.pitchNames == null) {
		tones_utils_NoteFrequencyUtil.pitchNames = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"];
		tones_utils_NoteFrequencyUtil.altPitchNames = [null,"Db",null,"Eb",null,null,"Gb",null,"Ab",null,"Bb",null];
	}
	this.noteFrequencies = new Float32Array(128);
	this.noteNames = [];
	this._octaveMiddleC = 3;
	this.set_tuningBase(440.0);
};
tones_utils_NoteFrequencyUtil.__name__ = true;
tones_utils_NoteFrequencyUtil.detuneFreq = function(freq,cents) {
	if(cents < 0) return freq / Math.pow(2,-cents * 0.00083333333333333339); else if(cents > 0) return freq * Math.pow(2,cents * 0.00083333333333333339);
	return freq;
};
tones_utils_NoteFrequencyUtil.prototype = {
	reset: function() {
		var _g = 0;
		while(_g < 128) {
			var i = _g++;
			this.noteNames[i] = this.indexToName(i);
			this.noteFrequencies[i] = this.get_tuningBase() * Math.pow(2,(i - 69.0) * 0.083333333333333329);
		}
	}
	,noteNameToIndex: function(name) {
		var hasAlternate = name.indexOf("/");
		if(hasAlternate != -1) name = name.substring(0,hasAlternate);
		var s;
		var i = this.noteNames.length;
		while(--i > -1) {
			s = this.noteNames[i];
			if(s.indexOf(name) > -1) return i;
		}
		return -1;
	}
	,noteNameToFrequency: function(name) {
		var i = this.noteNameToIndex(name);
		return i > -1?this.get_tuningBase() * Math.pow(2,(i - 69.0) * 0.083333333333333329):NaN;
	}
	,indexToName: function(index) {
		var pitch = index % 12;
		var octave = (index * 0.083333333333333329 | 0) - (5 - this.get_octaveMiddleC());
		var noteName = tones_utils_NoteFrequencyUtil.pitchNames[pitch] + octave;
		if(tones_utils_NoteFrequencyUtil.altPitchNames[pitch] != null) noteName += "/" + tones_utils_NoteFrequencyUtil.altPitchNames[pitch] + octave;
		return noteName;
	}
	,get_tuningBase: function() {
		return this._tuningBase;
	}
	,set_tuningBase: function(value) {
		this._tuningBase = value;
		this.invTuningBase = 1.0 / (this._tuningBase * 0.5);
		this.reset();
		return this._tuningBase;
	}
	,get_octaveMiddleC: function() {
		return this._octaveMiddleC;
	}
	,__class__: tones_utils_NoteFrequencyUtil
};
var tones_utils_Wavetables = function() {
	this.loadComplete = new hxsignal_impl_Signal0();
	this.loadAll();
};
tones_utils_Wavetables.__name__ = true;
tones_utils_Wavetables.prototype = {
	loadAll: function() {
		this.data = [];
		this.successCount = 0;
		this.errorCount = 0;
		var _g = 0;
		var _g1 = tones_utils_Wavetables.FileNames;
		while(_g < _g1.length) {
			var name = _g1[_g];
			++_g;
			var http = new haxe_Http("data/wavetables/" + name);
			http.onError = $bind(this,this.onDataError);
			var tmp;
			var f = [$bind(this,this.onData)];
			var a2 = [name];
			tmp = (function(a2,f) {
				return function(a1) {
					f[0](a1,a2[0]);
				};
			})(a2,f);
			http.onData = tmp;
			http.request();
		}
	}
	,onData: function(content,name) {
		var json = JSON.parse(content);
		this.data.push({ name : name.substring(0,name.length - 5), real : new Float32Array(json.real), imag : new Float32Array(json.imag)});
		this.successCount++;
		this.checkComplete();
	}
	,checkComplete: function() {
		if(this.errorCount + this.successCount == tones_utils_Wavetables.FileNames.length) {
			console.log("complete - loaded " + this.successCount + " (" + tones_utils_Wavetables.FileNames.length + ") wavetables");
			this.loadComplete.emit();
		}
	}
	,onDataError: function(_) {
		this.errorCount++;
		this.checkComplete();
	}
	,__class__: tones_utils_Wavetables
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
var node = window.OscillatorNode;
if(node != null) {
	if(Object.prototype.hasOwnProperty.call(node,"SINE")) {
		window.OscillatorTypeShim = {SINE:node.SINE, SQUARE:node.SQUARE, TRIANGLE:node.TRIANGLE, SAWTOOTH:node.SAWTOOTH, CUSTOM:node.CUSTOM}
	} else {
		window.OscillatorTypeShim = {SINE:"sine", SQUARE:"square", TRIANGLE:"triangle", SAWTOOTH:"sawtooth", CUSTOM:"custom"}
	}
}
haxe_ds_ObjectMap.count = 0;
js_Boot.__toStr = {}.toString;
tones_utils_Wavetables.FileNames = ["Bass.json","Bass_Amp360.json","Bass_Fuzz.json","Bass_Fuzz_2.json","Bass_Sub_Dub.json","Bass_Sub_Dub_2.json","Brass.json","Brit_Blues.json","Brit_Blues_Driven.json","Buzzy_1.json","Buzzy_2.json","Celeste.json","Chorus_Strings.json","Dissonant_1.json","Dissonant_2.json","Dissonant_Piano.json","Dropped_Saw.json","Dropped_Square.json","Dyna_EP_Bright.json","Dyna_EP_Med.json","Ethnic_33.json","Full_1.json","Full_2.json","Guitar_Fuzz.json","Harsh.json","Mkl_Hard.json","Noise.json","Organ_2.json","Organ_3.json","Phoneme_ah.json","Phoneme_bah.json","Phoneme_ee.json","Phoneme_o.json","Phoneme_ooh.json","Phoneme_pop_ahhhs.json","Piano.json","Putney_Wavering.json","TB303_Square.json","Throaty.json","Trombone.json","TwelveStringGuitar.json","Twelve_OpTines.json","Warm_Saw.json","Warm_Square.json","Warm_Triangle.json","Wurlitzer.json","Wurlitzer_2.json"];
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}});
