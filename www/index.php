
<!-- This is the project specific website template -->
<!-- It can be changed as liked or replaced by other content -->

<?php

$domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
$group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']);
$themeroot='http://r-forge.r-project.org/themes/rforge/';

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en   ">

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><?php echo $group_name; ?></title>
	<link href="<?php echo $themeroot; ?>styles/estilo1.css" rel="stylesheet" type="text/css" />
  </head>

<body>

<!-- R-Forge Logo -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr><td>
<a href="/"><img src="<?php echo $themeroot; ?>/images/logo.png" border="0" alt="R-Forge Logo" /> </a> </td> </tr>
</table>


<!-- get project title  -->
<!-- own website starts here, the following may be changed as you like -->

<?php if ($handle=fopen('http://'.$domain.'/export/projtitl.php?group_name='.$group_name,'r')){
$contents = '';
while (!feof($handle)) {
	$contents .= fread($handle, 8192);
}
fclose($handle);
echo $contents; } ?>

<!-- end of project description -->

<h3>Bayesian Additive Models for Location Scale and Shape (and Beyond)</h3>
The R package bamlss is a general tool for complex Bayesian regression modeling
with structured additive predictors based on Markov chain Monte Carlo simulation.
The design of this package substantially focuses on maximum flexibility and easy
integration of new code and/or standalone systems (e.g., JAGS and BayesX).
<p> Supplemtary files: </p>
<ul>
<li> The <a href="DAGStat2016.pdf">DAGStat 2016 slides</a>,</li>
<li> Slides from a talk at <a href="Linz2015.pdf">JKU Linz 2015</a>.</li>
</ul>

<h3>The R interface to BayesX</h3>
The R package R2BayesX provides an interface to BayesX, a software tool for estimating structured
additive regression models (STAR).  With R2BayesX, STAR models can be conveniently specified using
Rs formula language (with some extended terms), fitted using the BayesX binary, represented in R
with objects of suitable classes, and finally printed/summarized/plotted.
<p> Supplemtary files for the interface package R2BayesX: </p>
<ul>
<li> The <a href="https://www.jstatsoft.org/article/view/v063i21" target="_new">R2BayesX paper</a>,</li>
<li> The <a href="useR2011.pdf">useR! 2011 slides</a>,</li>
<li> together with the <a href="useR2011.R">R code from the useR! 2011 slides</a>.</li>
<li> The <a href="zambia.R">ZambiaNutrition demo</a> is containing example code for MCMC and STEP estimation,</li>
<li> and the <a href="forest.R">ForestHealth demo</a> illustrates estimation using REML.</li>
</ul>

<h3>The R Package Distribution of the BayesX C++ Sources</h3>
The R package BayesXsrc provides the BayesX command line tool for easy installation.
A convenient R interface is provided in package R2BayesX.

<p> The <strong>project summary page</strong> you can find <a href="http://<?php echo $domain; ?>/projects/<?php echo $group_name; ?>/"><strong>here</strong></a>. </p>

<p><a href="precipitation_clim.tar.gz">Supplementary material</a> for
the article "Spatio-Temporal Precipitation Climatology over Complex
Terrain Using a Censored Additive Regression Model"</p>
</body>
</html>
