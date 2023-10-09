/**
 * Created by krzysztofkalata on 09/07/2020.
 */

public abstract class TB_CustomWithStackTraceException extends Exception {
        private String stackTrackString = createStackTraceString();

        public override String getStackTraceString() {
            return stackTrackString;
        }

        private String createStackTraceString() {
            stackTrackString = new DmlException().getStackTraceString();
            return stackTrackString.replaceFirst('(?m)(.*\\n){3}?', '');
        }
    }