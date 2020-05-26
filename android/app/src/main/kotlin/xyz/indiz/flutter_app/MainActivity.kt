package xyz.indiz.flutter_app
import android.app.Activity
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
    private var prstate:Boolean=false
  private val CHANNEL = "samples.flutter.io/imagelist"
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)


      MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
          if (call.method == "getfollder") {
            if(checkSelfPermission()){
                var list=  loadAllImages()

                var fl:ArrayList<HashMap<String,Any>> = ArrayList()
                for(i in list.listIterator()){
                    var map:HashMap<String,Any> = HashMap()
                    map["fname"]=i.folderNames;
                    map["img"]=i.imagePath;
                    map["count"]=i.imgCount;
                    map["isvideo"]=i.isVideo;
                }
                result.success(fl)
            }
            else{
              requestPermission()
                if (prstate){
                    var list=  loadAllImages()
                    var fl:ArrayList<HashMap<String,Any>> = ArrayList()
                    for(i in list.listIterator()){
                        var map:HashMap<String,Any> = HashMap()
                        map["fname"]=i.folderNames;
                        map["img"]=i.imagePath;
                        map["count"]=i.imgCount;
                        map["isvideo"]=i.isVideo;
                    }
                    result.success(fl)
                }
                else{
                    result.error("error","permission not granted",null)
                }
            }
          }else if (call.method == "getimage")
          {
           var taxt=call.argument<String>("fname")
          //var isvide=call.argument<String>("isvideo")
           var list= getAllShownImagesPathh(this,taxt,false)
              if(list!=null){
                  result.success(list)
              }
              else{
                  result.error("error","error in loding in image",null)
              }
          }
          else {
              result.notImplemented()
          }

      }



  }

  private fun   requestPermission() {
    ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE), 6036)
  }

  private fun checkSelfPermission(): Boolean {

      return ActivityCompat.checkSelfPermission(this, android.Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
  }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        when (requestCode) {
            6036 -> {
                if (grantResults.size > 0) {
                    val permissionGranted: Boolean = grantResults[0] == PackageManager.PERMISSION_GRANTED
                    prstate = permissionGranted
                }
            }
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    fun loadAllImages(): ArrayList<Albums> {
        var imagesList = getAllShownImagesPath(this)
        return imagesList
    }



    private fun getAllShownImagesPathh(activity: Activity, folderName: String?, isVideo: Boolean?): MutableList<String> {

        val uri: Uri
        val cursorBucket: Cursor
        val column_index_data: Int
        val listOfAllImages = ArrayList<String>()
        var absolutePathOfImage: String? = null

        val selectionArgs = arrayOf("%$folderName%")

        uri = android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val selection = MediaStore.Images.Media.DATA + " like ? "

        val projectionOnlyBucket = arrayOf(MediaStore.MediaColumns.DATA, MediaStore.Images.Media.BUCKET_DISPLAY_NAME)

        cursorBucket = activity.contentResolver.query(uri, projectionOnlyBucket, selection, selectionArgs, null)

        column_index_data = cursorBucket.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA)

        while (cursorBucket.moveToNext()) {
            absolutePathOfImage = cursorBucket.getString(column_index_data)
            if (absolutePathOfImage != "" && absolutePathOfImage != null)
                listOfAllImages.add(absolutePathOfImage)
        }
        return listOfAllImages.asReversed()
    }



}

