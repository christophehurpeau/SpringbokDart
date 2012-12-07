part of chapps;

class SiteController extends AppController{
  SiteController(HttpRequest req,HttpResponse resp) : super(req,resp);
  
  Index(){
    renderText("ok!!");
  }
}
