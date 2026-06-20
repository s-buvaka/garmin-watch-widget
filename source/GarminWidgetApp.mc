import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;

// Main application class
class GarminWidgetApp extends Application.AppBase {

    function initialize() {
            AppBase.initialize();
                }

                    // Return the initial view of your application here
                        function getInitialView() {
                                return [new GarminWidgetView(), new GarminWidgetDelegate()];
                                    }
                                    }

                                    // Main view class
                                    class GarminWidgetView extends WatchUi.View {

                                        function initialize() {
                                                View.initialize();
                                                    }

                                                        // Load your resources here
                                                            function onLayout(dc as Graphics.Dc) as Void {
                                                                    setLayout(Rez.Layouts.MainLayout(dc));
                                                                        }

                                                                            // Called when this View is brought to the foreground
                                                                                function onShow() as Void {
                                                                                    }

                                                                                        // Update the view
                                                                                            function onUpdate(dc as Graphics.Dc) as Void {
                                                                                                    // Get and show the current time
                                                                                                            var clockTime = System.getClockTime();
                                                                                                                    var timeString = Lang.format("$1$:$2$", [
                                                                                                                                clockTime.hour.format("%02d"),
                                                                                                                                            clockTime.min.format("%02d")
                                                                                                                                                    ]);
                                                                                                                                                    
                                                                                                                                                            // Call the parent onUpdate function to redraw the layout
                                                                                                                                                                    View.onUpdate(dc);
                                                                                                                                                                    
                                                                                                                                                                            // Draw time string in the center of the screen
                                                                                                                                                                                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                                                                                                                                                                                            dc.drawText(
                                                                                                                                                                                                        dc.getWidth() / 2,
                                                                                                                                                                                                                    dc.getHeight() / 2,
                                                                                                                                                                                                                                Graphics.FONT_LARGE,
                                                                                                                                                                                                                                            timeString,
                                                                                                                                                                                                                                                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                                                                                                                                                                                                                                                                );
                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                        // Called when this View is removed from the screen
                                                                                                                                                                                                                                                                            function onHide() as Void {
                                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                // Input delegate class
                                                                                                                                                                                                                                                                                class GarminWidgetDelegate extends WatchUi.BehaviorDelegate {
                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                    function initialize() {
                                                                                                                                                                                                                                                                                            BehaviorDelegate.initialize();
                                                                                                                                                                                                                                                                                                }
                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                    function onMenu() as Boolean {
                                                                                                                                                                                                                                                                                                            WatchUi.pushView(
                                                                                                                                                                                                                                                                                                                        new Rez.Menus.MainMenu(),
                                                                                                                                                                                                                                                                                                                                    new GarminWidgetMenuDelegate(),
                                                                                                                                                                                                                                                                                                                                                WatchUi.SLIDE_UP
                                                                                                                                                                                                                                                                                                                                                        );
                                                                                                                                                                                                                                                                                                                                                                return true;
                                                                                                                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                                                                                                                    }
