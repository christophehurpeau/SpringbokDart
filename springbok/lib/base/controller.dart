part of springbok;

class Controller{
  final HttpRequest req;
  final HttpResponse resp;
  
  Controller(HttpRequest this.req,HttpResponse this.resp);
  
  dispatch(String action){
    print('dispatch: $action');
    reflect(this).invoke(action,[]).then((InstanceMirror retval){
      print(retval);
    });
    print('dispatched: $action');
  }
  
  
  renderText(String text){
    _write(text);
  }
  
  _write(String text,[status=200]){
    resp.statusCode = status;
    resp.contentLength = text.length;
    resp.outputStream.writeString(text);
    resp.outputStream.close();
  }
  
  redirect404(String url){
    resp.headers.set('Refresh', '0; url=$url');
    resp.headers.set(HttpHeaders.CONTENT_TYPE, 'text/html');
    _write('<!DOCTYPE html>'
           '<head><meta http-equiv="Refresh" content="0; url=\'$url\'"></head>'
           '<body>Page requested cannot be found. <a href="$url">Click here to be redirected</a></body>'
           '</html>'
        ,HttpStatus.NOT_FOUND);
  }
}
