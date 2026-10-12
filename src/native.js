// Native bridge: exposes Capacitor plugins to the (framework-free) web app as window.CapNative.
import { Capacitor, CapacitorHttp } from '@capacitor/core';
import { Geolocation } from '@capacitor/geolocation';
import { Share } from '@capacitor/share';
import { KeepAwake } from '@capacitor-community/keep-awake';
import { App } from '@capacitor/app';
import { StatusBar, Style } from '@capacitor/status-bar';
import { SplashScreen } from '@capacitor/splash-screen';
import { Device } from '@capacitor/device';
import { Filesystem, Directory, Encoding } from '@capacitor/filesystem';

if (Capacitor.isNativePlatform()) {
  window.CapNative = { Geolocation, Share, KeepAwake, App, Device, Filesystem, Directory, Encoding, Http: CapacitorHttp, platform: Capacitor.getPlatform() };
  StatusBar.setStyle({ style: Style.Dark }).catch(() => {});
  if (Capacitor.getPlatform() === 'android') StatusBar.setOverlaysWebView({ overlay: true }).catch(() => {});
  Geolocation.requestPermissions().catch(() => {});
  App.addListener('backButton', () => {
    if (window.__back && window.__back()) return;
    App.minimizeApp();
  });
  App.addListener('appUrlOpen', ({ url }) => { if (window.__openLink) window.__openLink(url); });
  window.addEventListener('load', () => setTimeout(() => SplashScreen.hide().catch(() => {}), 300));
}
