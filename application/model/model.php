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

    public function getPricingForBundle($bundleID, $zipCode){
        $ServiceCode='';
        $Provider='';
        $MedicareAvg=0;
        $AverageAmt=0;
        $params = array(
            array($bundleID, SQLSRV_PARAM_IN),
            array($zipCode, SQLSRV_PARAM_IN),
            array($ServiceCode, SQLSRV_PARAM_OUT),
            array($Provider, SQLSRV_PARAM_OUT),
            array($MedicareAvg, SQLSRV_PARAM_OUT),
            array($AverageAmt, SQLSRV_PARAM_OUT)
        );

        $sql = "{call dbo.SP_GetPricing( ?, ?)}";

        $prices = sqlsrv_query($this->db, $sql, $params);

        $priceList=[];

        while ($price = sqlsrv_fetch_array($prices, SQLSRV_FETCH_ASSOC)) {
            $po=new stdClass();
            $po->serviceCode=$price['ServiceCode'];
            $po->providerType=$price['Provider'];
            $po->medicareAvg=$price['MedicareAvg'];
            $po->averageAmount=$price['AverageAmt'];

            $priceList[]=$po;
        }

        return $priceList;
    }



    public function getMasterProcedures(){
        $sql = "SELECT distinct ProcedureID, ProcedureName FROM [dbo].[NS_Procedure] Order by ProcedureName";
        return sqlsrv_query($this->db, $sql);
    }

    public function getBundlesForProcedure($procedureCode){
        $params = array($procedureCode);
        $sql = "Select * from dbo.NS_Bundle where ProcedureID=?";
        $bundles = sqlsrv_query($this->db, $sql, $params);
        $bundleList =[];

        while ($row = sqlsrv_fetch_array($bundles)){
            $bundle=new stdClass();
            $bundle->id=$row['ID'];
            $bundle->name=$row['BundleName'];
            $bundle->procedureID=$row['ProcedureID'];
            $bundleList[]=$bundle;
        }
        return $bundleList;
    }
}
