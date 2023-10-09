public with sharing class TB_StaticTest {
    private static Boolean doNotRunTriggers = false;

    public static void setDoNotRunTriggers(){
        doNotRunTriggers = true;
    }

    public static void unsetDoNotRunTriggers(){
        doNotRunTriggers = false;
    }

    public static Boolean shouldRunTriggers() {
        return !doNotRunTriggers;
    }
}