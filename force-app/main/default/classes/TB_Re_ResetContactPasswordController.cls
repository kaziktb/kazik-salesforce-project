public with sharing class TB_Re_ResetContactPasswordController {
    @InvocableMethod(label='Reset Password')
    public static void resetPassword(List<String> email) {
        TB_ExperienceAuthenticationController.sendChangePasswordEmail(email[0]);
    }
}