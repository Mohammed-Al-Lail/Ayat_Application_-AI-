import 'package:flutter/material.dart';


// ignore: must_be_immutable
class DrawerlistTail extends StatefulWidget {

   DrawerlistTail({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    
    
    });

    String title;
    IconData? icon ;
    void Function()? onTap;

  @override
  State<DrawerlistTail> createState() => _DrawerlistTailState();
}

class _DrawerlistTailState extends State<DrawerlistTail> {

  bool _isEnter = false;

  

  
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 50),

      child: MouseRegion(

        onEnter: (event){
          setState(() {
            _isEnter=!_isEnter;
          });
        },

        onExit:(event){
          setState(() {
            _isEnter=!_isEnter;
          });
        }, 

        child: ListTile(

          onTap: widget.onTap ,
        
          title: Text(
            widget.title,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
            ),
        
           
            tileColor: _isEnter? Colors.grey[600]:Colors.grey[400],
        
            trailing: ClipRRect(
              borderRadius: BorderRadius.circular(30),
        
              child: Container(
                width: 50,
                height: 50,
                color: Colors.grey,
               
        
                child: Icon(
                  widget.icon,
                  color: Colors.grey[800],
                  size: 30,
                ),
              ),
            ),
        
            iconColor: Colors.grey,
        ),
      ),
    );

  }
}