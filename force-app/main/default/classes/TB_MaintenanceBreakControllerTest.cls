@IsTest
private class TB_MaintenanceBreakControllerTest {
    static final Boolean BREAK_TRUE = true;
    static final Integer TIME_PERIOD = 5;

    @IsTest
    static void shouldReturnCustomSet_whenUserHasRecord(){
        //given
        TB_Maintenance_Break__c maintenanceBreak = new TB_Maintenance_Break__c();
        maintenanceBreak.SetupOwnerId = UserInfo.getUserId();
        maintenanceBreak.TB_Refresh_Period__c = TIME_PERIOD;
        maintenanceBreak.TB_Is_Maintenance_Break__c = BREAK_TRUE;
        insert maintenanceBreak;

        TB_Commerce_Maintenance_Break__c maintenanceCommerceBreak = new TB_Commerce_Maintenance_Break__c();
        maintenanceCommerceBreak.SetupOwnerId = UserInfo.getUserId();
        maintenanceCommerceBreak.TB_Refresh_Period__c = TIME_PERIOD;
        maintenanceCommerceBreak.TB_Is_Maintenance_Break__c = BREAK_TRUE;
        insert maintenanceCommerceBreak;

        TB_Admissions_Maintenance_Break__c maintenanceAdmissionsBreak = new TB_Admissions_Maintenance_Break__c();
        maintenanceAdmissionsBreak.SetupOwnerId = UserInfo.getUserId();
        maintenanceAdmissionsBreak.TB_Refresh_Period__c = TIME_PERIOD;
        maintenanceAdmissionsBreak.TB_Is_Maintenance_Break__c = BREAK_TRUE;
        insert maintenanceAdmissionsBreak;

        TB_Virtual_University_Maintenance_Break__c maintenanceVirtualUniversityBreak = new TB_Virtual_University_Maintenance_Break__c();
        maintenanceVirtualUniversityBreak.SetupOwnerId = UserInfo.getUserId();
        maintenanceVirtualUniversityBreak.TB_Refresh_Period__c = TIME_PERIOD;
        maintenanceVirtualUniversityBreak.TB_Is_Maintenance_Break__c = BREAK_TRUE;
        insert maintenanceVirtualUniversityBreak;
        	
		TB_Contract_Teachers_Maintenance_Break__c maintenanceCTBreak = new TB_Contract_Teachers_Maintenance_Break__c();
        maintenanceCTBreak.SetupOwnerId = UserInfo.getUserId();
        maintenanceCTBreak.TB_Refresh_Period__c = TIME_PERIOD;
        maintenanceCTBreak.TB_Is_Maintenance_Break__c = BREAK_TRUE;
        insert maintenanceCTBreak;
        
        //when
        TB_Maintenance_Break__c result;
        TB_Commerce_Maintenance_Break__c resultCommerce;
        TB_Admissions_Maintenance_Break__c resultAdmissions;
        TB_Virtual_University_Maintenance_Break__c resultVirtualUniversity;
        TB_Contract_Teachers_Maintenance_Break__c resultContractTeachers;
        sObject resultNull;
        Test.startTest();
        result = TB_MaintenanceBreakController.getMaintenanceBreak();
        resultCommerce = (TB_Commerce_Maintenance_Break__c)TB_MaintenanceBreakController.getPortalMaintenanceBreak('Commerce');
        resultAdmissions = (TB_Admissions_Maintenance_Break__c)TB_MaintenanceBreakController.getPortalMaintenanceBreak('admissions');
        resultVirtualUniversity = (TB_Virtual_University_Maintenance_Break__c)TB_MaintenanceBreakController.getPortalMaintenanceBreak('Virtual_University');
        resultContractTeachers = (TB_Contract_Teachers_Maintenance_Break__c)TB_MaintenanceBreakController.getPortalMaintenanceBreak('Contract_Teachers');
        resultNull = TB_MaintenanceBreakController.getPortalMaintenanceBreak('something else');
        Test.stopTest();

        //then
        System.assertEquals(BREAK_TRUE, result.TB_Is_Maintenance_Break__c);
        System.assertEquals(TIME_PERIOD, result.TB_Refresh_Period__c);

        System.assertEquals(BREAK_TRUE, resultCommerce.TB_Is_Maintenance_Break__c);
        System.assertEquals(TIME_PERIOD, resultCommerce.TB_Refresh_Period__c);

        System.assertEquals(BREAK_TRUE, resultAdmissions.TB_Is_Maintenance_Break__c);
        System.assertEquals(TIME_PERIOD, resultAdmissions.TB_Refresh_Period__c);

        System.assertEquals(BREAK_TRUE, resultVirtualUniversity.TB_Is_Maintenance_Break__c);
        System.assertEquals(TIME_PERIOD, resultVirtualUniversity.TB_Refresh_Period__c);
		
		System.assertEquals(BREAK_TRUE, resultContractTeachers.TB_Is_Maintenance_Break__c);
		System.assertEquals(TIME_PERIOD, resultContractTeachers.TB_Refresh_Period__c);

        System.assertEquals(null, resultNull);
    }
}