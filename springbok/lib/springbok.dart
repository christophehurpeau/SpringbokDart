library springbok;

import 'dart:io';
import 'dart:json' as JSON;

part 'http_response.dart';
part 'base/controller.dart';
part 'base/action.dart';
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
https://github.com/lvivski/hart
*/

const DEV=true;

/** a Springbok App */
class App{
  static final HttpServer _server = new HttpServer();
  
  /** Init then start the app and the server */
  static start(Map controllers,String appPath,[host='127.0.0.1', int port=3000]){
    if(!appPath.endsWith('/')) appPath='${appPath}/';
    String serverPath='${appPath}server/';
    print(new File('${serverPath}config/routes.json').readAsStringSync());
    final router=new Router(
      JSON.parse(new File('${serverPath}config/routes.json').readAsStringSync()),
      JSON.parse(new File('${serverPath}config/routesLangs.json').readAsStringSync())
    );
    
    _server
      ..defaultRequestHandler=(HttpRequest req, HttpResponse response){
        SpringbokHttpResponse resp=new SpringbokHttpResponse(response);
        print(req.path);
        if(req.path == "/favicon.ico"){
          (new File('web/favicon.ico')).openInputStream().pipe(response.outputStream);
        }else if(req.path.length > 5 && req.path.substring(0,5)=='/web/'){
          final File file = new File('${appPath}web${req.path}');
          file.exists().then((bool found){
            if(!found) resp.notFound();
            else{
              file.fullPath().then((String fullPath){
                if (!fullPath.startsWith(appPath)) resp.notFound();
                else file.openInputStream().pipe(response.outputStream);
              });
            }
          });
        }else{
          try{
            Route route=router.find(req.path);
            if(route==null) resp.notFound();
            else{
              print("${route.controller} ${route.action}");
              /*http://blog.dartwatch.com/2012/06/dartmirrors-reflection-api-is-on-way.html, http://phylotic.blogspot.fr/2012/08/working-with-mirrors-in-dart-brief.html*/
              
              controllers[route.controller][route.action].apply(req,resp);
              /*ClassMirror cm=ms.libraries['chapps'].classes['${route.controller}Controller'];
              cm.newInstance('',[reflect(req),reflect(resp)])
                .then((InstanceMirror newClass){
                  newClass.reflectee.dispatch(route.action);
                });*/
              //new ClassMirror(route.controller).newInstance(route.controller,[req,resp]).then((InstanceMirror m) => m.invoke(route.action));
            }
          }catch(e,stack){
            response.statusCode = 500;
            print("${e.toString()}\n${stack.toString()}");
            response.outputStream..writeString("Internal Server Error\n")
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