/*
* @(#)InstrucaoMontador.java  1.0  27/11/2002
*	
* Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/

import java.util.*;

/**
* <i>InstrucaoMontador</i> armazena os dados referentes a uma instru��o da arquitetura.
*/
public class InstrucaoMontador
{
	private String mneumonico;
	private String instrucaoAssociada;
	private int nregistradores;
	private int nconstantes;
	private int nlabels;
	private int npalavras;
	private int nciclos;
	private String[] codigo=new String[4];
	private String[] campoEscrita=new String[4];
	private String[] campoMontagem=new String[4];

	public InstrucaoMontador(String mneu,String inst,int nreg,int nconst,int nlab,int npal,int nciclo,String[] cod,String[] campEsc)
	{
		mneumonico=mneu;
		instrucaoAssociada=inst;
		nregistradores=nreg;
		nconstantes=nconst;
		nlabels=nlab;
		npalavras=npal;
		nciclos=nciclo;
		codigo=cod;
		campoEscrita=campEsc;
		campoMontagem=null;
	}

	public InstrucaoMontador(String mneu,String inst,int nreg,int nconst,int nlab,int npal,int nciclo,String[] cod,String[] campEsc,String [] campMont)
	{
		mneumonico=mneu;
		instrucaoAssociada=inst;
		nregistradores=nreg;
		nconstantes=nconst;
		nlabels=nlab;
		npalavras=npal;
		nciclos=nciclo;
		codigo=cod;
		campoEscrita=campEsc;
		campoMontagem=campMont;
	}


	/**
	* Retorna o Mneumonico.
	*/
	public String getMneumonico(){return mneumonico;}

	/**
	* Retorna o nome da instrucao no simulador associada ao mneumonico.
	*/
	public String getInstrucaoMontadorAssociada(){return instrucaoAssociada;}

	/**
	* Retorna o n�mero de registradores utilizados pela instru��o.
	*/
	public int getNRegistradores(){return nregistradores;}

	/**
	* Retorna o n�mero de constantes utilizadas pela instru��o.
	*/
	public int getNConstantes(){return nconstantes;}

	/**
	* Retorna o n�mero de labels utilizados pela instru��o.
	*/
	public int getNLabels(){return nlabels;}

	/**
	* Retorna o n�mero de palavras utilizadas pela instru��o.
	*/
	public int getNPalavras(){return npalavras;}

	/**
	* Retorna o n�mero de ciclos de rel�gio utilizadas pela instru��o em sua execu��o.
	*/
	public int getNCiclos(){return nciclos;}

	/**
	* Retorna o c�digo da instrucao na posi��o informada pelo indice.
	*/
	public String getCodigo(int indice){return codigo[indice];}

	/**
	* Retorna o c�digo da instrucao.
	*/
	public String[] getCodigo(){return codigo;}

	/**
	* Retorna o campo de escrita da instrucao na posi��o informada pelo indice.
	*/
	public String getCampoEscrita(int indice){return campoEscrita[indice];}

	/**
	* Retorna o campo de escrita da instrucao.
	*/
	public String[] getCamposEscrita(){return campoEscrita;}

	/**
	* Retorna o campo de montagem da instrucao na posi��o informada pelo indice.
	*/
	//public String getCampoMontagem(int indice){return campoMontagem[indice];}

	/**
	* Retorna o campo de montagem da instrucao.
	*/
	//public String[] getCamposMontagem(){return campoMontagem;}

	/**
	* Retorna o indice do campo de montagem informado .
	*/
	/*public int getIndiceCampoMontagem(String campo)
	{
		for(int i=0;i<campoMontagem.length;i++)
		{
			if(campoMontagem[i].equalsIgnoreCase(campo))
				return i;
		}
		return -1;
	}
	*/
	
	/**
	* Captura o pseudo codigo do campo informado.
	* RT -3
	* RS1 -1 
	* RS2 -2
	*/
	public String getPseudoCodigo(String camp)
	{
		if(camp.equals("RS1"))
			return "-1";
		else if(camp.equals("RS2"))
			return "-2";
		else if(camp.equals("RT"))
			return "-3";
		return "0";
	}

	
	/**
	* Captura o indice do codigo que possui o pseudo codigo.
	*/
	public int getIndicePseudoCodigo(String pseudoCodigo)
	{
		for(int i=0;i<codigo.length;i++)
		{
			if(codigo[i].trim().equalsIgnoreCase(pseudoCodigo))
				return i;
		}
		return -1;
	}

	/**
	* Verifica se o codigo do indice informado nao � pseudo codigo, ou seja,
	* indice possui seu codigo definitivo.
	*/
	public boolean isCodigoResolvido(int indice)
	{
		if(!isPseudoCodigo(codigo[indice]))	
			return true;
		return false;
	}
	
	/**
	* Verifica se o codigo informado � pseudo codigo, ou seja,
	* indice possui codigo n�o resolvido, logo tem o sinal (-) no primeiro byte.
	*/
	public boolean isPseudoCodigo(String cod)
	{
		if(cod.substring(0,1).equals("-"))	
			return true;
		return false;
	}

	/**
	* Exibe o codigo da instru��o.
	*/
	public void exibeCodigo()
	{
		System.out.println("Codigo:"+codigo[0]+" "+codigo[1]+" "+codigo[2]+" "+codigo[3]+" ");
	}

	/**
	* Exibe os dados da instru��o.
	*/
	public void exibe()
	{
		System.out.print(mneumonico+" "+instrucaoAssociada+" ");
		System.out.print(nregistradores+" "+nconstantes+" "+nlabels+" "+npalavras+" "+nciclos+" ");
		System.out.print(codigo[0]+" "+codigo[1]+" "+codigo[2]+" "+codigo[3]+" ");
		System.out.print(campoEscrita[0]+" "+campoEscrita[1]+" "+campoEscrita[2]+" "+campoEscrita[3]+" ");
		System.out.println(campoMontagem[0]+" "+campoMontagem[1]+" "+campoMontagem[2]+" "+campoMontagem[3]);
	}
}