part of springbok;

class SpringbokHttpResponse{
  HttpResponse _resp;
  
  SpringbokHttpResponse(HttpResponse this._resp);
  
  notFound(){
    _resp.statusCode = HttpStatus.NOT_FOUND;
    _resp.outputStream.close();
  }
  
  text(String text){
    _resp.outputStream
      ..writeString(text)
      ..close();
  }
}

