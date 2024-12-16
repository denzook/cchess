import QtQuick.Window 2.0
import QtQuick 2.6
import QtQuick.Controls 2.0

//Rectangle {
//    x: 0
//    y: 0
//    width: 600
//    height: 800
Window {
    width: 600
    height: 800
    color: "#ffffff"
    visible: true
    //title: qsTr("Hello World")

    property var bridge : null


    Timer {
        id: timer
        interval: 200;
        running: false
        onTriggered: {
            txtTotalTime.text = timer_string(board.elapsed)
            txtRedTime.text = timer_string(board.elapsed_red)
            txtBlkTime.text = timer_string(board.elapsed_blk)
            running = true
        }
    }
    Item {
        id: itemsize
        width:52*board.width/578
        height:width
        visible:false
    }
    onSceneGraphInitialized: btnReset.clicked()

    Item {
        id: board
        objectName: "board"
        states: [
            State { name: "click" },
            State { name: "AI" },
            State { name: "busy" },
            State { name: "over" }
        ]
        state: "click"
        property var selected: null
        property var side: 1 // 1-RED, 2-BLACK
        property int undosize: 0

        property var elapsed: timer_reset()
        property var elapsed_red: timer_reset()
        property var elapsed_blk: timer_reset()
        property bool checkBool : false
        property var  moves: []
        property var  gens: [ppp16,rpp16]
        property var  pieces :  [ ppp00, ppp01, ppp02, ppp03, ppp04,
            ppp10, ppp11, ppp12, ppp13, ppp14, ppp15, ppp16, ppp17, ppp18, ppp19, ppp1a,
            rpp00, rpp01, rpp02, rpp03, rpp04,
            rpp10, rpp11, rpp12, rpp13, rpp14, rpp15, rpp16, rpp17, rpp18, rpp19, rpp1a,
           ]

        //width: 578
        //height: 638
        width: Math.min(parent.width-40,578*(parent.height-160)/638)
        height: width*638/578
        z: 0
        anchors.top: parent.top
        anchors.topMargin: 40

//        anchors.left: parent.left
//        anchors.leftMargin: 40

//        anchors.right: parent.right
//        anchors.rightMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        Image {
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            //fillMode: Image.PreserveAspectFit
            source: "img/board.svg"

        }
        Item {
            id : item1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 45*itemsize.height/52
            anchors.right: parent.right
            anchors.rightMargin: 45*itemsize.width/52
            anchors.top: parent.top
            anchors.topMargin: 45*itemsize.height/52
            anchors.left: parent.left
            anchors.leftMargin: 45*itemsize.width/52
            Image { id:iselected // visible: true;  property int posx: 0; property int posy: 3; width: 52; height: 52;
                    width: itemsize.width*2; height: itemsize.height*2;
                    x:(!visible)?0:board.selected.x+board.selected.width/2-width/2;
                    y:(!visible)?0:board.selected.y+board.selected.height/2-height/2;
                    source: "img/rnd-sel.png";  visible: (board.selected != null) }

//            Image { // visible: true;  property int posx: 0; property int posy: 3; width: 52; height: 52;
//                    x:0;  y: 0;  source: "rnd-blue.png"; visible: false }
//            Image { // visible: true;  property int posx: 0; property int posy: 3; width: 52; height: 52;
//                    x:0;  y: 0;  source: "rnd-red.png"; visible: false }

            Image {  id:checked; visible: board.checkBool;
                        width: itemsize.width*2; height: itemsize.height*2;
                        property int posx:  (board.side==1)?ppp16.posx:rpp16.posx;
                        property int posy:  (board.side==1)?ppp16.posy:rpp16.posy;
                        x:toPixel(Qt.point(posx,posy),this).x; y: toPixel(Qt.point(posx,posy),this).y;
                        source: "img/rnd-white.png" }

            Image {  id:ppp00; visible: true;  property int posx: 0; property int posy: 300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;  source: "img/red-pawn.svg" }
            Image {  id:ppp01; visible: true;  property int posx: 200; property int posy: 300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-pawn.svg" }
            Image {  id:ppp02; visible: true;  property int posx: 400; property int posy: 300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-pawn.svg" }
            Image {  id:ppp03; visible: true;  property int posx: 600; property int posy: 300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-pawn.svg" }
            Image {  id:ppp04; visible: true;  property int posx: 800; property int posy: 300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-pawn.svg" }

            Image {  id:ppp10; visible: true;  property int posx: 100; property int posy: 200; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-cannon.svg" }
            Image {  id:ppp11; visible: true;  property int posx: 800-100; property int posy: 200; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-cannon.svg" }

            Image {  id:ppp12; visible: true;  property int posx: 0; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-char.svg" }
            Image {  id:ppp13; visible: true;  property int posx: 100; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-knight.svg" }
            Image {  id:ppp14; visible: true;  property int posx: 200; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-xiang.svg" }
            Image {  id:ppp15; visible: true;  property int posx: 300; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-guard.svg" }
            Image {  id:ppp16; visible: true;  property int posx: 400; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-gen.svg" }
            Image {  id:ppp17; visible: true;  property int posx: 800-300; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-guard.svg" }
            Image {  id:ppp18; visible: true;  property int posx: 800-200; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-xiang.svg" }
            Image {  id:ppp19; visible: true;  property int posx: 800-100; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-knight.svg" }
            Image {  id:ppp1a; visible: true;  property int posx: 800-0; property int posy: -0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-char.svg" }


            Image {  id:rpp00; visible: true;  property int posx: 0; property int posy: 900-300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-pawn.svg" }
            Image {  id:rpp01; visible: true;  property int posx: 200; property int posy: 900-300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-pawn.svg" }
            Image {  id:rpp02; visible: true;  property int posx: 400; property int posy: 900-300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-pawn.svg" }
            Image {  id:rpp03; visible: true;  property int posx: 600; property int posy: 900-300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-pawn.svg" }
            Image { id:rpp04; visible: true;  property int posx: 800; property int posy: 900-300; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-pawn.svg" }

            Image {  id:rpp10; visible: true;  property int posx: 100; property int posy: 900-200; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-cannon.svg" }
            Image {  id:rpp11; visible: true;  property int posx: 800-100; property int posy: 900-200; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-cannon.svg" }

            Image {  id:rpp12; visible: true;  property int posx: 0; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-char.svg" }
            Image {  id:rpp13; visible: true;  property int posx: 100; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-knight.svg" }
            Image {  id:rpp14; visible: true;  property int posx: 200; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-xiang.svg" }
            Image {  id:rpp15; visible: true;  property int posx: 300; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-guard.svg" }
            Image {  id:rpp16; visible: true;  property int posx: 400; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-gen.svg" }
            Image {  id:rpp17; visible: true;  property int posx: 800-300; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-guard.svg" }
            Image {  id:rpp18; visible: true;  property int posx: 800-200; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-xiang.svg" }
            Image {  id:rpp19; visible: true;  property int posx: 800-100; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-knight.svg" }
            Image {  id:rpp1a; visible: true;  property int posx: 800-0; property int posy: 900-0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/blk-char.svg" }

            Image {  id:shadow; visible: false; opacity:.7; property int posx: 0; property int posy: 0; width: itemsize.width; height: itemsize.height;z:1;
                    x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;   source: "img/red-pawn.svg" }
        }
        Text {
            id: txtCheck
            x: 0
            y: 291*itemsize.height/52
            color: (board.side==1)?"red":"black"
            anchors.right: parent.right
            anchors.left: parent.left
            text: qsTr("%1: CHECK !!").arg((board.side==1)?"RED":"BLACK")
            visible: (board.state == "click" || board.state == "AI")&&board.checkBool
            //anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Raised
            horizontalAlignment: Text.AlignHCenter
            font.italic: true
            font.bold: true
            font.family: "Arial"
            textFormat: Text.PlainText
            font.pixelSize: 48
            opacity: 1.0
            onVisibleChanged: visible?checkAnim.start():checkAnim.stop()

            SequentialAnimation {
                id: checkAnim
                PropertyAnimation { target: txtCheck; properties: "opacity"; to: 1.0; duration: 200  }
                PropertyAnimation { target: txtCheck;properties: "opacity"; to: 0.0; duration: 300  }
                //PauseAnimation { duration: 150  }
                loops: Animation.Infinite
            }
        }
        MouseArea {
            id: mousearea
            hoverEnabled: true
            anchors.fill: parent
            z: 2
            onPositionChanged : {
                var pt = mapToItem(item1, mouseX, mouseY)
                if((pt = toPoint(pt)) != undefined) {
                    txtPos.text = qsTr("%1 , %2").arg( parseInt(pt.x/100)).arg(parseInt(pt.y/100));
                    var a = board.moves.find(function(e){return e.posx == pt.x && e.posy == pt.y})
                    if(a !== undefined)
                    {
                        shadow.x = a.x+a.width/2-shadow.width/2
                        shadow.y = a.y+a.height/2-shadow.height/2
                        shadow.visible=true
                    }
                    else shadow.visible=false
                }
            }
            onClicked: {
                var pt=toPoint(mapToItem(item1, mouseX, mouseY))
                var a = board.moves.find(function(e){ return (pt.x == e.posx && pt.y == e.posy) })
                //(bridge == null)?undefined:

                if(board.state=="click" && board.gens[0].opacity != 0.0 && board.gens[1].opacity != 0.0)
                {
                    if(a!==undefined && board.selected !==null)
                    {
                        updatePos(board.selected, pt)
                        anim.func = function(){  setSide(); }
                        anim.start()
                        board.selected = null;
                    }
                    else {
                        board.selected =
                            (board.selected != null &&
                            pt.y == board.selected.posy && pt.x == board.selected.posx)?null:getpiece(pt)
                    }
                }
                board.moves.forEach(function(e){ e.destroy()})
                board.moves=[]
                if(board.selected != null ) {
                    shadow.source = board.selected.source
                    if(bridge == null) getavailable()
                    else  getavailable2(bridge.getValidPlace(board.selected))
                    //setSide(1)

                }
                else shadow.visible=false
            }
        }
        Component
        {
            id: animcomp
            ParallelAnimation
            {
                id: anim20
                property var value;
                PropertyAnimation {target: anim20.value['item']; property: "posx"; to: anim20.value['x']; duration:75 }
                PropertyAnimation {target: anim20.value['item']; property: "posy"; to: anim20.value['y']; duration:75 }
                PropertyAnimation {target: anim20.value['item']; property: "opacity"; to: anim20.value['opacity']; duration:75 }
            }
        }
        SequentialAnimation {
            id: anim
            property var func: null
            animations:[]
//            animations:[
//                ParallelAnimation {
//                PropertyAnimation {target: ppp00; property: "x"; to: 5; duration:100 }
//                PropertyAnimation {target: ppp00; property: "y"; to: 5; duration:100 }
//                PropertyAnimation {target:  ppp00; property: "opacity"; to: 0.5; duration:100 }
//                }
//            ]
            onStopped:{
                for(var i =0;i<animations.length; i ++) animations[i].destroy()
                animations=[]
                if(func!=null) { var f = func; func = null; f();  }
            }
        }
    }
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        height:120
        width: parent.width
        x:0

        Text {
            id: text2
            x: parent.width-600+357
            y: 120-800+684
            width: 117
            height: 19
            text: qsTr("Total time:")
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.AutoText
            font.family: "Arial"
            font.pointSize: 10
        }

        Text {
            id: txtTotalTime
            x: parent.width-600+480
            y: 120-800+684
            width: 94
            height: 19
            text: ""
            font.family: "Arial"
            textFormat: Text.AutoText
            font.pointSize: 10
        }

        Text {
            id: text4
            x: parent.width-600+357
            y: 120-800+709
            width: 117
            height: 19
            text: qsTr("Player time:")
            color: "red"
            horizontalAlignment: Text.AlignLeft
            font.family: "Arial"
            textFormat: Text.AutoText
            font.pointSize: 10
        }

        Text {
            id: text5
            x: parent.width-600+357
            y: 120-800+734
            width: 117
            height: 19
            text: qsTr("Comp time:")
            color: "black"
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.AutoText
            font.family: "Arial"
            font.pointSize: 10
        }

        Text {
            id: txtRedTime
            x: parent.width-600+480
            y: 120-800+709
            width: 94
            height: 19
            text: ""
            textFormat: Text.AutoText
            font.family: "Arial"
            font.pointSize: 10
        }

        Text {
            id: txtBlkTime
            x: parent.width-600+480
            y: 120-800+734
            width: 94
            height: 19
            text: ""
            textFormat: Text.AutoText
            font.family: "Arial"
            font.pointSize: 10
        }

        Text {
            id: text8
            x: parent.width-600+357
            y: 120-800+765
            width: 117
            height: 19
            text: qsTr("Position:")
            horizontalAlignment: Text.AlignLeft
            font.family: "Arial"
            textFormat: Text.AutoText
            font.pointSize: 10
        }

        Text {
            id: txtPos
            x: parent.width-600+480
            y: 120-800+765
            width: 94
            height: 19
            text: qsTr("0 , 0")
            horizontalAlignment: Text.AlignHCenter
            font.family: "Arial"
            textFormat: Text.AutoText
            font.pointSize: 10
        }

        Button {
            id: btnUndo
            x: 22
            y: 120-800+750
            width: 114
            height: 34
            text: qsTr((board.undosize>0)?qsTr("Undo - %1").arg(board.undosize):"Undo")
            enabled: (board.undosize>0)
            onClicked: {
                var side = board.side
                if(bridge == null || board.state=="busy") return
                //if(board.gens[0].opacity==0.0) side = 1
                //else if(board.gens[1].opacity==0.0) side = 2
                side = 1; // always side = RED for now due to AI

                btnUndo.enabled = (board.undosize = bridge.undo(side))>0
                anim.func = function(){ setSide(side) }
                anim.start()
            }
        }

        Button {
            id: btnReset
            x: 158
            y: 120-800+750
            width: 112
            height: 34
            text: qsTr("Reset")
            enabled: false
            onClicked: {
                if(board.state=="busy") return
                board.undosize = 0
                btnUndo.enabled = false
                board.selected = null
                board.moves.forEach(function(e){ e.destroy()})
                board.moves=[]
                shadow.visible = false
                if(bridge != null) bridge.reset()
                setSide(1)
                timer.running=false
                btnReset.enabled = false
                board.checkBool = false
                timer_reset(board.elapsed)
                timer_reset(board.elapsed_red)
                timer_reset(board.elapsed_blk)
                txtTotalTime.text = ""
                txtRedTime.text = ""
                txtBlkTime.text = ""
                board.state="click"
            }
        }

        Text {
            id: text10
            x: 22
            y: 120-800+684
            width: 94
            height: 19
            text: qsTr("Side:")
            horizontalAlignment: Text.AlignLeft
            textFormat: Text.AutoText
            font.family: "Arial"
            font.pointSize: 10
        }

        Text {
            id: txtSide
            x: 127
            y: 120-800+684
            width: 94
            height: 19
            color: (board.side==1)?"red":"black"
            text: (board.side==1)?qsTr("RED"):qsTr("BLACK")
            font.family: "Arial"
            textFormat: Text.AutoText
            font.pointSize: 10
        }
    }


//    function createPiece(type, side, pos) {
//        //Qt.createQmlObject('import QtQuick 2.0; Rectangle {color: "red"; width: 20; height: 20}', item1);
//        var comp;
//        if ((comp = Qt.createComponent("Image.qml")).status == Component.Ready) {
//                var w = ppp00.width, h = ppp00.height;
//                obj = comp.createObject(item1, {x: toPixel(pos).x-w/2, y: toPixel(pos).y-h/2,
//                                                     width: w, height: h,
//                                                     source: qStr("%1-%2.svg").arg((side==1)?"red":"blk")
//                                                                .arg(   (type==1)?"pawn":
//                                                                        (type==2)?"cannon":
//                                                                        (type==3)?"char":
//                                                                        (type==4)?"knight":
//                                                                        (type==5)?"xiang":
//                                                                        (type==6)?"guard":
//                                                                        "gen")})
//                if(objname != undefined) obj.objectName = objname
//                return obj
//        }
//        return undefined;
//    }


    function toPixel(pt, item) { // pos in object { x,y}
        var px = Qt.point(0,0)
        px.x = pt.x * item1.width/800 - ((item===undefined)?0:(item.width/2))
        px.y = ((pt.y < 500) ? (pt.y * item1.height/900) : (item1.height - (900-pt.y) * item1.height/900)) -
                ((item===undefined)?0:(item.height/2))
        return px
    }

    function toPoint(px) { // pos in object { x,y}
        var pt = Qt.point(0,0)
        var rect

        pt.x = parseInt(.5+px.x * 8 / item1.width)
        if(px.y >= item1.height/2)
        {
            pt.y = parseInt(0.5+9 - (item1.height - px.y) * 9 / item1.height)
        }
        else pt.y = parseInt(px.y * 9 / item1.height + .5)

        rect=Qt.rect(pt.x*item1.width/8-ppp00.width/2,
                     pt.y*item1.height/9-ppp00.height/2,
                     ppp00.width,ppp00.height)

        pt.x *= 100; pt.y *= 100;
        if(px.x>=rect.left && px.x < rect.right &&
            px.y>=rect.top && px.y < rect.bottom ) return pt;

        return undefined
    }

    function putpiece(obj, pt) { // pos in object { x,y}
        var px = toPoint(pt)
        obj.x=pt.px.x; obj.y=pt.px.y
    }

    function getpiece(pos,side){
        if(side==undefined) side = board.side
        var a = (pos === null || pos === undefined)?undefined:
                                board.pieces.find(function(e){
                                    if(e.opacity == 0.0) return false
                                    if(e.posx != pos.x || e.posy != pos.y) return false
                                    var b = qsTr(e.source.toString()).split("/").slice(-1)[0]
                                    return (side==1 && b.startsWith("red-")) ||
                                            (side==2 && b.startsWith("blk-"))
                                    })
        return (a === undefined) ?  null : a
    }

    function getavailable2(pts) {
        if(pts == null)  return
        pts.forEach(function(e){
            var obj=null
            var a = board.pieces.find(function(p){ return (p.opacity != 0.0 && p.posx === e.x && p.posy === e.y)  })
            if(a !== undefined &&
               ((board.side==1 && a.source.toString().split("/").slice(-1)[0].startsWith("blk-"))||
                (board.side==2 && a.source.toString().split("/").slice(-1)[0].startsWith("red-")))
              )
            {
                obj=Qt.createQmlObject("import QtQuick 2.6\n"+qsTr('Image { property int posx: %1; property int posy: %2;' +
                                   'width: itemsize.width*2; height: itemsize.height*2;'+
                                   'x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;'+
                                   'source: "img/rnd-red.png"; visible:true }').arg(e.x).arg(e.y), item1)
            }
            else if(a === undefined) {
                obj=Qt.createQmlObject("import QtQuick 2.6\n"+qsTr('Image { property int posx: %1; property int posy: %2;' +
                                    'width: itemsize.width*2; height: itemsize.height*2;'+
                                   'x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;'+
                                   'source: "img/rnd-blue.png"; visible:true }').arg(e.x).arg(e.y), item1)
            }
            if(obj !== null){
                board.moves.push(obj)
            }
        })
    }

    function getavailable() {
        for (var x = 0; x < 900; x +=100)
            for (var y = 0; y < 1000; y +=100)
            {
                var a = board.pieces.find(function(e){return  e.opacity != 0.0 && e.posx == x && e.posy == y})
                var obj=null

                if(a !== undefined &&
                   ((board.side==1 && a.source.toString().split("/").slice(-1)[0].startsWith("blk-"))||
                    (board.side==2 && a.source.toString().split("/").slice(-1)[0].startsWith("red-")))
                  )
                {
                    obj=Qt.createQmlObject("import QtQuick 2.6\n"+qsTr('Image { property int posx: %1; property int posy: %2;' +
                                        'width: itemsize.width*2; height: itemsize.height*2;'+
                                       'x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;'+
                                       'source: "img/rnd-red.png"; visible:true }').arg(x).arg(y), item1)
                }
                else if(a === undefined) {
                    obj=Qt.createQmlObject("import QtQuick 2.6\n"+qsTr('Image { property int posx: %1; property int posy: %2;' +
                                        'width: itemsize.width*2; height: itemsize.height*2;'+
                                       'x:toPixel(Qt.point(posx,posy),this).x; y:toPixel(Qt.point(posx,posy),this).y;'+
                                       'source: "img/rnd-blue.png"; visible:true }').arg(x).arg(y), item1)
                }
                if( obj !== null)
                {
//                    obj.x = toPixel(obj.pos).x-obj.width/2
//                    obj.y = toPixel(obj.pos).y-obj.height/2
//                    obj.visible=true
                    board.moves.push(obj)
                }
            }
    }

    function getAllPieces() { return board.pieces }
    function setChecked(bool) { board.checkBool = bool }
    function updatePos(item, pt, forundo) {
        var remove =(forundo==undefined||forundo==false)?
                    getpiece(pt, item.source.toString().split("/").slice(-1)[0].startsWith("red-")?2:1):null

//        if(updatexy=== undefined) updatexy = false
//        if(updatexy)
//        {
//            item.posx = pt.x
//            item.posy = pt.y
//            item.opacity = 1.0
//            return;
//        }
        board.state="busy"
        var pos=Qt.point(item.posx, item.posy)
        for(var i = 0; i < anim.animations.length; i ++)
        {
            var a = anim.animations[i]
            if(a['value']['item']==item) pos=Qt.point(a['value']['x'],a['value']['y'])
        }
        var paths=getpaths(pos, pt)
        paths.forEach(function(e,i,a){
            anim.animations.push(animcomp.createObject(board, {'value': {'item':item, 'x':e.x, 'y':e.y, 'opacity':1.0 }}))
        })


        if(bridge != null)
        {
            btnUndo.enabled=((board.undosize = bridge.updatePos(pt, item, remove, forundo))>0)
        }

        if(remove !== null)
        {
            anim.animations.push(animcomp.createObject(board, {'value': {'item':remove, 'x':remove.posx, 'y':remove.posy,
                                                               'opacity':0.0 }}))
            //remove.opacity=0.0
        }
        if(!btnReset.enabled)
        {
            timer_start(board.elapsed)
            timer.running = true
            btnReset.enabled = true
        }
    }

    function doneAI (piece, pos){
        updatePos(piece, pos)
        anim.func = function(){  setSide(); }
        anim.start()
    }


    function setSide(side) {
        var max = 99*3600000+59*60000+59000+999;
        if(side==undefined) board.side = (board.side == 1)? 2 : 1
        else board.side = side

        if(board.side == 1) { timer_start(board.elapsed_red); timer_pause(board.elapsed_blk); }
        else  { timer_start(board.elapsed_blk); timer_pause(board.elapsed_red); }
        timer_start(board.elapsed)
        timer.running = true

        if(bridge != null)
        {
            var a = bridge.killTheGen(board.side)
            var gen=board.gens[(board.side==1)?1:0]

            if(a !== null) {

                timer.running = false
                timer_pause(board.elapsed)
                timer_pause(board.elapsed_red)
                timer_pause(board.elapsed_blk)
                updatePos(a,Qt.point(gen.posx,gen.posy))
                anim.func = function(){ board.state = "over" }
                anim.start()
            }
            else
            {
                if(board.side == 1)  board.state = "click"
                else {
                    board.state = "AI"
                    bridge.useAI(board.side)
                }
            }
        }
        else board.state = "click"

        //if((a=bridge.killTheGen)
    }

    function getpaths(oldpos, newpos){
        var ydelta, xdelta;
        var delta = Math.max( Math.abs(oldpos.x-newpos.x),Math.abs(oldpos.y-newpos.y))
        var x = 0, y = 0;
        var out = []
        //if(oldpos.x == -1) { delta = 0; oldpos= newpos }
        //if(newpos.x == -1) { delta = 0; }
        if(delta == 0) out.push(Qt.point(oldpos.x,oldpos.y))

        for (var n=0; n < delta; n +=100)
        {
            var xdelta = Math.abs(newpos.x-oldpos.x-x)
            var ydelta = Math.abs(newpos.y-oldpos.y-y)

            if(xdelta >= ydelta) x += ((newpos.x > oldpos.x)?100:-100)
            if(ydelta >= xdelta) y += ((newpos.y > oldpos.y)?100:-100)
            out.push(Qt.point(x+oldpos.x,y+oldpos.y))
        }
        return out
    }


    function timer_string(timer)
    {
        var t, max = 99*3600000+59*60000+59000+999;
        if((t = timer[0]+((timer[1] == null)?0:(new Date()-timer[1])))>=max)
        {
            t = timer[0] = max; timer[1] = null
        }
        return qsTr("%1:%2:%3.%4").arg( qsTr("0%1").arg(parseInt(t/3600000)).slice(-2)) //
                                    .arg(qsTr("0%1").arg(parseInt(t%3600000/60000)).slice(-2))
                                    .arg(qsTr("0%1").arg(parseInt(t%60000/1000)).slice(-2))
                                    .arg(qsTr("00%1").arg(parseInt(t%1000)).slice(-3))
    }

    function timer_pause(timer)
    {
        var t, max = 99*3600000+59*60000+59000+999;
        if((t = timer[0]+((timer[1] === null)?0:(new Date()-timer[1])))>=max) t = max
        timer[0] = t; timer[1] = null

    }
    function timer_reset(timer) {
        if(timer==undefined) return  [0, null]
        timer[0]=0; timer[1]=null; return timer
    }

    function timer_start(timer) { if(timer[1] === null) timer[1] =new Date() }

}

