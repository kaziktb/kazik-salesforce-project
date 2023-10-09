public abstract class CustomException extends Exception {
    public class MissingBypassException extends CustomException {}
    public class CommunityUserWithoutContactException extends CustomException {}
    public class ApprovalProcessLogicNotFoundException extends CustomException {}
    public class ApprovalProcessStageLogicNotFoundException extends CustomException {}
    public class ApprovalProcessNoLongerActiveException extends CustomException {}
    public class ApprovalProcessNotExistsException extends CustomException {}

    public CustomException saveLog() {
        Logger.saveLog(this);
        return this;
    }
}