library springbok;

import 'dart:io';
import 'dart:json';
import 'dart:mirrors';

part 'base/controller.dart';
part 'base/server.dart';
part 'base/router.dart';
part 'base/router_route.dart';



part 'utils/u_string.dart';

/* https://github.com/maiah/synth/blob/master/lib/synth.dart 
https://github.com/d2m/dartlang/blob/master/html5demos.com/history/history.dart
https://github.com/dart-lang/dartlang.org/tree/master/src/site
https://github.com/dart-lang/dart-html5-samples/blob/master/web/indexeddb/todo/todo.dart
https://github.com/eee-c/hipster-mvc/tree/master/lib
https://github.com/rikulo/rikulo
*/

const DEV=true;

_send404(HttpResponse response){
  response.statusCode = HttpStatus.NOT_FOUND;
  response.outputStream.close();
}

/** a Springbok App */
class App{
  static final HttpServer _server = new HttpServer();
  static final Map<String,Controller> controllers=new Map();
  
  /** Init then start the app and the server */
  static start(String appPath,[host='127.0.0.1', int port=3000]){
    if(!appPath.endsWith('/')) appPath='${appPath}/';
    String serverPath='${appPath}server/';
    print(new File('${serverPath}config/routes.json').readAsStringSync());
    final router=new Router(
      JSON.parse(new File('${serverPath}config/routes.json').readAsStringSync()),
      JSON.parse(new File('${serverPath}config/routesLangs.json').readAsStringSync())
    );
    
    final MirrorSystem ms = currentMirrorSystem();
    
    _server
      ..defaultRequestHandler=(HttpRequest req, HttpResponse resp){
        print(req.path);
        if(req.path == "/favicon.ico"){
          (new File('web/favicon.ico')).openInputStream().pipe(resp.outputStream);
        }else if(req.path.length > 5 && req.path.substring(0,5)==='/web/'){
          final File file = new File('${appPath}web${req.path}');
          file.exists().then((bool found){
            if(!found) _send404(resp);
            else{
              file.fullPath().then((String fullPath){
                if (!fullPath.startsWith(appPath)) _send404(resp);
                else file.openInputStream().pipe(resp.outputStream);
              });
            }
          });
        }else{
          try{
            Route route=router.find(req.path);
            if(route==null) _send404(resp);
            else{
              print("${route.controller} ${route.action}");
              /*http://blog.dartwatch.com/2012/06/dartmirrors-reflection-api-is-on-way.html, http://phylotic.blogspot.fr/2012/08/working-with-mirrors-in-dart-brief.html*/
              ClassMirror cm=ms.libraries['chapps'].classes['${route.controller}Controller'];
              cm.newInstance('',[reflect(req),reflect(resp)])
                .then((InstanceMirror newClass){
                  newClass.reflectee.dispatch(route.action);
                });
              //new ClassMirror(route.controller).newInstance(route.controller,[req,resp]).then((InstanceMirror m) => m.invoke(route.action));
            }
          }catch(e,stack){
            resp.statusCode = 500;
            print("${e.toString()}\n${stack.toString()}");
            resp.outputStream..writeString("Internal Server Error\n")
                             ..writeString(e.toString())
                             ..writeString("\n")
                             ..writeString(stack.toString())
                             ..close();
          }
        }
      }
      ..listen(host, port);
  }
}