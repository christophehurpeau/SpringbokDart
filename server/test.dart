library chapps;

import '../springbok/lib/springbok.dart';
import 'dart:io';

part './AppController.dart';
part 'controllers/Site.dart';


main(){
  final controllers={'Site':SiteController()};
  App.start(controllers,new Directory.current().path);
}