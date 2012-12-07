part of springbok;

class RouterRoute{
  String controller,action,ext;
  int paramsCount;
  final Map<String,RouterRouteLang> _routes=new Map();
  List<String> params;
  
  RouterRoute(String c_a){
    var c__a=c_a.split('.');
    this.controller=c__a[0];
    this.action=c__a[1];
  }
  
  RouterRouteLang operator [](String lang) => this._routes[lang];
  operator []=(String lang,RouterRouteLang route) => this._routes[lang]=route; 
}

class RouterRouteLang{
  RegExp regExp;
  String strf;
  RouterRouteLang(RegExp this.regExp,String this.strf){
    if(this.strf!=='/') this.strf=UString.rtrim(this.strf,'/');
  }
}