/**
 * @description Class for all DML operations
 * @author Oleg Bezrukov
 * @date 07-2023
 */
public with sharing class DMLExecutor {

    private static final String DML_ERROR_MSG= 'You have no permission to {0} this object: {1}';

    /**
     * @description Method checks user permissions to perform DML and runs Database.insert()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static void doInsert(List<SObject> objList){
        DMLExecutor.doInsert(objList, true); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.insert()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static List<Database.SaveResult> doInsert(List<SObject> objList, Boolean allOrNone)
    {
        if (objList == null || objList.isEmpty()) {
            return new List<Database.SaveResult>();
        }
        SObjectType myType = objList[0].getSObjectType();
        if (!myType.getDescribe().isCreateable()) {
            throw new DmlExecutorException(
                String.format(DML_ERROR_MSG, new List<Object>{'insert', myType})
            );
        }
        return Database.insert(objList, allOrNone);
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.update()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static void doUpdate(List<SObject> objList){
        DMLExecutor.doUpdate(objList, true); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.update()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static List<Database.SaveResult> doUpdate(List<SObject> objList, Boolean allOrNone)
    {
        if (objList == null || objList.isEmpty()){
            return new List<Database.SaveResult>();
        }
        SObjectType myType = objList[0].getSObjectType();
        if (!myType.getDescribe().isUpdateable()) {
            throw new DmlExecutorException(
                String.format(DML_ERROR_MSG, new List<Object>{'update', myType})
            );
        }
        return Database.update(objList, allOrNone);
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.upsert()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static void doUpsert(List<SObject> objList){
        DMLExecutor.doUpsert(objList, null); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.upsert()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static void doUpsert(List<SObject> objList, Schema.SObjectField externalIDField){
        DMLExecutor.doUpsert(objList, externalIDField, true); 
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.upsert()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static List<Database.UpsertResult> doUpsert(List<SObject> objList, Schema.SObjectField externalIDField, Boolean allOrNone)
    {
        if (objList == null || objList.isEmpty()){
            return new List<Database.UpsertResult>();
        }
        SObjectType myType = objList[0].getSObjectType();
        if (myType.getDescribe().isCreateable() == false || myType.getDescribe().isUpdateable() == false) {
            throw new DmlExecutorException(String.format(DML_ERROR_MSG, new List<Object>{'insert or update', myType}));
        }
        return Database.upsert(objList, externalIDField, allOrNone);
    }

    /**
     * @description Method checks user permissions to perform DML and runs Database.delete()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static void doDelete(List<SObject> objList){
        DMLExecutor.doDelete(objList, true); 
    }
    
    /**
     * @description Method checks user permissions to perform DML and runs Database.delete()
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public static List<Database.DeleteResult> doDelete(List<SObject> objList, Boolean allOrNone)
    {
        if (objList == null || objList.isEmpty()){
            return new List<Database.DeleteResult>();
        }
        SObjectType myType = objList[0].getSObjectType();
        if (myType.getDescribe().isDeletable() == false) {
            String.format(DML_ERROR_MSG, new List<Object>{'delete', myType});
        }
        return Database.delete(objList, allOrNone);
    }

    /**
     * @description Exception class
     * @author Oleg Bezrukov
     * @date 07-2023
     */
    public class DmlExecutorException extends Exception {}

}
