part of chapps;

SiteController(){
  return new Controller({
    'Index':new Action((req,res){
      res.text("ok!!");
    })
  });
}