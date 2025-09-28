package com.ss.ams.swivel_secure_authenticator

import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val PLATFORM_CHANNEL = "com.ss.ams/platform"
    private val SECURITY_CHANNEL = "com.ss.ams/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Platform channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLATFORM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppSignature" -> {
                    result.success(getAppSignature())
                }
                "isInstalledFromPlayStore" -> {
                    result.success(isInstalledFromPlayStore())
                }
                "getNetworkInfo" -> {
                    result.success(getNetworkInfo())
                }
                "isVpnActive" -> {
                    result.success(isVpnActive())
                }
                "getBatteryInfo" -> {
                    result.success(getBatteryInfo())
                }
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }
                "isAppInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    result.success(isAppInstalled(packageName ?: ""))
                }
                "getAppVersion" -> {
                    result.success(getAppVersion())
                }
                "getBuildNumber" -> {
                    result.success(getBuildNumber())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Security channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isRooted" -> {
                    result.success(isDeviceRooted())
                }
                "hasRootApps" -> {
                    result.success(hasRootApps())
                }
                "getSystemProperties" -> {
                    result.success(getSystemProperties())
                }
                "hasSecureLockScreen" -> {
                    result.success(hasSecureLockScreen())
                }
                "isScreenshotDetected" -> {
                    result.success(false) // Placeholder
                }
                "preventScreenshots" -> {
                    val prevent = call.argument<Boolean>("prevent") ?: false
                    preventScreenshots(prevent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getAppSignature(): String? {
        return try {
            val packageInfo = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            packageInfo.signatures?.get(0)?.toCharsString()
        } catch (e: Exception) {
            null
        }
    }

    private fun isInstalledFromPlayStore(): Boolean {
        val installer = packageManager.getInstallerPackageName(packageName)
        return installer == "com.android.vending"
    }

    private fun getNetworkInfo(): Map<String, Any> {
        return mapOf(
            "type" to "unknown",
            "isConnected" to true
        )
    }

    private fun isVpnActive(): Boolean {
        return false
    }

    private fun getBatteryInfo(): Map<String, Any> {
        return mapOf(
            "level" to 100,
            "isCharging" to false
        )
    }

    private fun getInstalledApps(): List<String> {
        return try {
            val packages = packageManager.getInstalledPackages(0)
            packages.map { it.packageName }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun getAppVersion(): String? {
        return try {
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            packageInfo.versionName
        } catch (e: Exception) {
            null
        }
    }

    private fun getBuildNumber(): String? {
        return try {
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode.toString()
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode.toString()
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun isDeviceRooted(): Boolean {
        return checkRootMethod1() || checkRootMethod2() || checkRootMethod3()
    }

    private fun checkRootMethod1(): Boolean {
        val buildTags = Build.TAGS
        return buildTags != null && buildTags.contains("test-keys")
    }

    private fun checkRootMethod2(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        return false
    }

    private fun checkRootMethod3(): Boolean {
        return try {
            Runtime.getRuntime().exec("su")
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun hasRootApps(): Boolean {
        val rootApps = arrayOf(
            "com.noshufou.android.su",
            "com.noshufou.android.su.elite",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.thirdparty.superuser",
            "com.yellowes.su",
            "com.topjohnwu.magisk"
        )

        for (packageName in rootApps) {
            if (isAppInstalled(packageName)) {
                return true
            }
        }
        return false
    }

    private fun getSystemProperties(): Map<String, String> {
        val properties = mutableMapOf<String, String>()
        try {
            properties["ro.debuggable"] = getSystemProperty("ro.debuggable", "0")
            properties["ro.secure"] = getSystemProperty("ro.secure", "1")
            properties["service.adb.root"] = getSystemProperty("service.adb.root", "0")
        } catch (e: Exception) {
            // Ignore
        }
        return properties
    }

    private fun getSystemProperty(key: String, defaultValue: String): String {
        return try {
            val process = Runtime.getRuntime().exec("getprop $key")
            process.inputStream.bufferedReader().readLine() ?: defaultValue
        } catch (e: Exception) {
            defaultValue
        }
    }

    private fun hasSecureLockScreen(): Boolean {
        return try {
            val lockPatternEnabled = Settings.Secure.getInt(contentResolver, Settings.Secure.LOCK_PATTERN_ENABLED, 0) != 0
            val passwordEnabled = Settings.Secure.getInt(contentResolver, "lockscreen.password_type", 0) != 0
            lockPatternEnabled || passwordEnabled
        } catch (e: Exception) {
            false
        }
    }

    private fun preventScreenshots(prevent: Boolean) {
        if (prevent) {
            window.setFlags(
                android.view.WindowManager.LayoutParams.FLAG_SECURE,
                android.view.WindowManager.LayoutParams.FLAG_SECURE
            )
        } else {
            window.clearFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
