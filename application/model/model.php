<?php

class Model
{
    /**
     * @param object $db A PDO database connection
     */
    function __construct($db)
    {
        try {
            $this->db = $db;
        } catch (PDOException $e) {
            exit('Database connection could not be established.');
        }
    }

//    public function getAllPricing(){
//        $sql = "EXEC [dbo].[SP_GetPricing] @procedureID = 1901 @zipCode = '53202'";
//        $cursorType = array("Scrollable" => SQLSRV_CURSOR_KEYSET);
//        $params = array(&$_POST['procedureId'],&$_POST['zipCode']);
//        return sqlsrv_query($this->db, $sql, $params, $cursorType);
//    }


    public function getAllPricing(){
        $procedureID=&$_POST['procedureID'];
        $zipCode=&$_POST['zipCode'];
        $ServiceCode='';
        $ProviderEntityCode='';
        $MedicareAvg=0;
        $AverageAmt=0;
        $params = array(
            array($procedureID, SQLSRV_PARAM_IN),
            array($zipCode, SQLSRV_PARAM_IN),
            array($ServiceCode, SQLSRV_PARAM_OUT),
            array($ProviderEntityCode, SQLSRV_PARAM_OUT),
            array($MedicareAvg, SQLSRV_PARAM_OUT),
            array($AverageAmt, SQLSRV_PARAM_OUT)
        );

        $sql = "{call dbo.SP_GetPricing( ?, ?)}";

        return sqlsrv_query($this->db, $sql, $params);
    }

    public function getMasterProcedures(){
        $sql = "SELECT distinct ProcedureID, ProcedureName FROM [dbo].[NS_Procedure_Mapping]";
//        $cursorType = array("Scrollable" => SQLSRV_CURSOR_KEYSET);
        return sqlsrv_query($this->db, $sql);
    }
}
