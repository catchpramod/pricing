<?php


class Pricing extends Controller
{

    public function index()
    {

        $procedureID=&$_POST['procedureID'];
        $zipCode=&$_POST['zipCode'];
        //get bundles for given procedure
        $bundleList = $this->model->getBundlesForProcedure($procedureID);
        //for each bundle, get pricing info
        $priceBundles=[];
        foreach($bundleList as $bundle){
            $prices = $this->model->getPricingForBundle($bundle->id, $zipCode);
            $priceBundles[$bundle->id] = $prices;
        }
        $procedures = $this->model->getMasterProcedures();
       // load views.
        require APP . 'views/_templates/header.php';
        require APP . 'views/pricing/index.php';
        require APP . 'views/_templates/footer.php';
    }


}
