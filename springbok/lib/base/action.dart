part of springbok;

class Action {
  final Function callback; 
  Action(Function this.callback) {
  }
  
  apply(req,res){
    Function.apply(this.callback,[req,res]);
  }
  
}
