/**
 * @description Apex Class to validate CRUD and perfom DML operations
 * @author Kostiantyn Murin
 * @date 18-06-2023
 */
public inherited sharing class DMLExecutor {

    /**
     * @description Method checks user permissions to perform DML and runs Database.insert()
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param objList SObjects to perform DML
     */
    public static void doInsert(List<SObject> objList){
        DMLExecutor.doInsert(objList, true); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.insert()
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param objList SObjects to perform DML
     * @param allOrNone specifies whether the operation allows partial success.
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> doInsert(List<SObject> objList, Boolean allOrNone)
    {
        if (objList == null || objList.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        SObjectType myType = objList[0].getSObjectType();
        if (!myType.getDescribe().isCreateable()) {
            throw new DmlExecutorException(
                String.format(Label.DML_Exception_Message, new List<Object>{'insert', myType})
            );
        }
        return Database.insert(objList, allOrNone);
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.update()
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param objList SObjects to perform DML
     */
    public static void doUpdate(List<SObject> objList){
        DMLExecutor.doUpdate(objList, true); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.update()
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param objList SObjects to perform DML
     * @param allOrNone specifies whether the operation allows partial success.
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> doUpdate(List<SObject> objList, Boolean allOrNone)
    {
        if (objList == null || objList.isEmpty()){
            return new List<Database.SaveResult>();
        }
        SObjectType myType = objList[0].getSObjectType();
        if (!myType.getDescribe().isUpdateable()) {
            throw new DmlExecutorException(
                String.format(Label.DML_Exception_Message, new List<Object>{'update', myType})
            );
        }
        return Database.update(objList, allOrNone);
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.upsert()
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param objList SObjects to perform DML
     */
    public static void doUpsert(List<SObject> objList){
        DMLExecutor.doUpsert(objList, null); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.upsert()
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param objList SObjects to perform DML
     * @param externalIDField is the field that upsert() uses to match sObjects with existing records
     */
    public static void doUpsert(List<SObject> objList, Schema.SObjectField externalIDField){
        DMLExecutor.doUpsert(objList, externalIDField, true); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.upsert()
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param objList SObjects to perform DML
     * @param externalIDField is the field that upsert() uses to match sObjects with existing records
     * @param allOrNone specifies whether the operation allows partial success.
     * @return List<Database.SaveResult>
     */
    public static List<Database.UpsertResult> doUpsert(List<SObject> objList, Schema.SObjectField externalIDField, Boolean allOrNone)
    {
        if (objList == null || objList.isEmpty()){
            return new List<Database.UpsertResult>();
        }
        SObjectType myType = objList[0].getSObjectType();
        if (myType.getDescribe().isCreateable() == false || myType.getDescribe().isUpdateable() == false) {
            throw new DmlExecutorException(String.format(Label.DML_Exception_Message, new List<Object>{'insert or update', myType}));
        }
        return Database.upsert(objList, externalIDField, allOrNone);
    }

    /**
     * @description Exception class
     * @author Kostiantyn Murin
     * @date 18-06-2023
     */
    public class DmlExecutorException extends Exception {}

}