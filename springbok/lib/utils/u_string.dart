part of springbok;

class UString {
  static String replaceAll(String s,RegExp from, String to(Match m,String string)){
    StringBuffer s2=new StringBuffer();
    int lastEndMatch=0;
    for(Match m in from.allMatches(s)) {
      if(m.start!=lastEndMatch) s2.add(s.substring(lastEndMatch,m.start));
      s2.add(to(m,s));
      lastEndMatch=m.end;
    }
    if(lastEndMatch != s.length) s2.add(s.substring(lastEndMatch));
    return s2.toString();
  }
  
  static String trim(String s,String pattern){
    return s.replaceFirst(new RegExp("^$pattern"),'').replaceFirst(new RegExp("$pattern\$"),'');
  }
  
  static String rtrim(String s,String pattern){
    return s.replaceFirst(new RegExp("$pattern\$"),'');
  }
  
  
  static String ucFirst(final String s){
    assert(s!==null);
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
  static String lcFirst(String s){
    assert(s!==null);
    return '${s[0].toLowerCase()}${s.substring(1)}';
  }
}
/*
main(){
  int i=0;
  String res=UString.replaceAll('/:id-:slug',new RegExp(r'(\(\?)?\:([a-zA-Z_]+)'),(Match m,String string){
    //print(m.noSuchMethod(invocation)reduce('',(prev,v) => prev+=', $v'));
    return '[${m[2]} (${i++})]';
  });
  print(res);
  assert(res=='/[id (0)]-[slug (1)]');
}*/