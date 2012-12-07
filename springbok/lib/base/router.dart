part of springbok;

class Route{
  final String all,controller,action,ext;
  final Map<String,String> nParams;
  final List<String> sParams;
  Route(String this.all,String this.controller,String this.action,Map<String,String> this.nParams,List<String> this.sParams,String this.ext);
}


class Router{
  final DEFAULT={'controller':'Site','action':'index'};
  
  final Map<String,Map<String,RouterRoute>> _routes=new Map();
  final Map<String,Map<String,String>> _routesLangs=new Map();
  
  Router(Map<String,dynamic> r,Map<String,dynamic> rl){
    print(r);
    if(!r.containsKey('index')){
      Map r2=new Map<String,Map<String,dynamic>>();
      r2['index']=r;
      r=r2;
    }
    
    r.forEach((String entry,Map<String,dynamic> entryRoutes){
      var classRoutes=this._routes[entry]=new Map<String,RouterRoute>();
      
      if(entryRoutes.containsKey('includesFromEntry')){
        if(entryRoutes['includesFromEntry'] is String) entryRoutes['includesFromEntry']=[entryRoutes['includesFromEntry']];
        for(var ife in entryRoutes['includesFromEntry']){
          if(ife is String) //entryRoutes.pushAll(r[ife]);
            r[ife].forEach((String k, Map v){ entryRoutes.putIfAbsent(k,() => v); });
          /*else
            ife.forEach((){
              for(var  in )
                entryRoutes[
            })
          */
        }
        entryRoutes.remove('includesFromEntry');
      }
      
      entryRoutes.forEach((url,List route){
        var finalRoute=this._routes[entry][url]=new RouterRoute(route[0]);
        Map<String,String> paramsDef = route.length>1 ? route[1] : null;
        String ext=null;
        if (route.length>3) ext = finalRoute.ext = route[3];
        Map<String,String> routesLang = route.length>2 ? route[2] : {};
        routesLang['_'] = url;
        
        routesLang.forEach((lang,String routeLang){
          var paramsNames=[],specialEnd,specialEnd2,routeLangPreg;
          if(specialEnd=routeLang.endsWith('/*'))
            routeLangPreg=routeLang.substring(0,routeLang.length-2);
          else if(specialEnd2=routeLang.endsWith('/*)?'))
            routeLangPreg=routeLang.substring(0,routeLang.length-4)
                        .concat(routeLang.substring(routeLang.length-2));
          else routeLangPreg=routeLang;
          routeLangPreg=routeLangPreg.replaceAll(r'/',r'\/')
                            .replaceAll(r'-',r'\-')
                            .replaceAll(r'*',r'(.*)')
                            .replaceAll(r'(',r'(?:');
          print(routeLangPreg);
          
          finalRoute[lang]=new RouterRouteLang(
            new RegExp(r"^".concat(UString.replaceAll(routeLangPreg,
                new RegExp(r'(\(\?)?\:([a-zA-Z_]+)'),(Match m,String s){
                  if(m[1]!==null) return m[0];
                  paramsNames.add(m[2]);
                  if(paramsDef!==null && paramsDef.containsKey(m[2])){
                    var paramDefVal=paramsDef[m[2]] is Map ? paramsDef[m[2]][lang] : paramsDef[m[2]];
                    return paramDefVal==='id' ? r'([0-9]+)' : '($paramDefVal)';
                  }
                  if(['id'].contains(m[2])) return '([0-9]+)';
                  return r'([^\/]+)';
              })).concat(ext!==null ? (ext==='html' ? r'(?:\.html)?':'\.$ext') : '').concat(r'$')
            ),
            routeLang=routeLang.replaceAll(new RegExp(r'(\:[a-zA-Z_]+)'),'%s')
                .replaceAll(new RegExp(r'[\?\(\)]'),'')
                .replaceAll('/*','%s')
                .trim()
          );
          if(!paramsNames.isEmpty) finalRoute.params=paramsNames;
        });
        finalRoute.paramsCount=finalRoute['_'].strf.split('%s').length-1;
      });
      
    });
    
    rl.forEach((String s,Map<String,String> tr){
      tr.forEach((String lang,String s2){
        if(!this._routesLangs.containsKey('->$lang')){
          this._routesLangs['->$lang']=new Map<String,String>();
          this._routesLangs['$lang->']=new Map<String,String>();
        }
        this._routesLangs['->$lang'][s]=s2;
        this._routesLangs['$lang->'][s2]=s;
      });
    });
  }
  
  // dart2js : regarder ici si iterator optimisé
  Route find(String all, [String lang='en',String entry='index']){
    all='/${UString.trim(all,'/')}';
    print('router : find: "$all"');
    for(RouterRoute route in this._routes[entry].values){
      RouterRouteLang routeLang=route[lang];
      if(routeLang===null) routeLang=route['_'];
      print('try: '.concat(routeLang.regExp.pattern));//.concat(routeLang[0].allMatches(all)));
      Match match=routeLang.regExp.firstMatch(all);
      
      if(match !== null){
        var c_a={'controller':route.controller,'action':route.action},nParams={},sParams=[]; // nParams=named params, sParams= simple params
        
        if(route.params!==null){
          var /*nbNamedParameters=route.params.length,*/countMatches=match.groupCount;
          if(countMatches !== 0){
            int group=1;
            for(var param in route.params) nParams[param]=match.group(group++);
            while(group <= countMatches) sParams.add(match.group(group++));
          }
          for(var v in ['controller','action']){
            if(c_a[v]=='!'){
              if(nParams.containsKey(v)){
                c_a[v]=UString.ucFirst(this.untranslate(nParams[v],lang));
                nParams.remove(v);
              }else c_a[v]=DEFAULT[v];
            }
          }
        }
        return new Route(all,c_a['controller'],c_a['action'],nParams,sParams,null);
      }
    }
    return null;
  }
  
  
  String getStringLink(params){
    var route=UString.trim(params,'/');
    var iFirstSlash=route.indexOf('/');
    if(iSecondSlash!=-1){
      
    }
  }
  
  String translate(String s,String lang){
    if(DEV){
      if(!this._routesLangs.containsKey('->$lang'))
        throw new Exception("Lang doesn't exist : $lang");
      if(!this._routesLangs['->$lang'].containsKey(s))
        throw new Exception("Missing traduction '$s' for lang '$lang'");
    }
    return this._routesLangs['->$lang'][s];
  }
  String untranslate(String s,String lang){
    if(DEV){
      if(!this._routesLangs.containsKey('$lang->'))
        throw new Exception("Lang doesn't exist : $lang");
      //if(!this._routesLangs['$lang->'].containsKey(s))
      //  throw new Exception("Missing traduction '$s' for lang '$lang'");
    }
    String t=this._routesLangs['$lang->'][s];
    return t===null ? s : t;
  }
}
