library chapps;

import '../springbok/lib/springbok.dart';
import 'dart:io';

part './AppController.dart';
part 'controllers/Site.dart';


main(){
  App.start(new Directory.current().path);
}