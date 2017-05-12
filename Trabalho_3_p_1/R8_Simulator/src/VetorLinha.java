/*
* @(#)VetorLinha.java  1.0  27/11/2002
*	
* Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/

import java.util.*;

/**
* <i>VetorLinha</i> contem a armazena as linhas de dados
*/
public class VetorLinha extends Vector
{
	//private Vector linhas;
	
	public VetorLinha()
	{
		super();
//		linhas=new Vector();
	}
	
	/**
	* Exibe as linhas do arquivo.
	*/
	public void exibeLinhas()
	{
		System.out.println("LINHAS ARQUIVO.ASM");
		
		for(int i=0;i<super.size();i++)
		{
			Linha linha=(Linha)super.get(i);
			linha.exibeLinha();	
		}
	}

	/**
	* Exibe os tokens das linhas do arquivo.
	*/
	public void exibeTokensLinhas()
	{
		System.out.println("TOKENS DAS LINHAS DO ARQUIVO.ASM");
		for(int i=0;i<super.size();i++)
		{
			Linha linha=(Linha)super.get(i);
			linha.exibeTokens();	
		}
	}

	/**
	* Exibe o codigo objeto das linhas do arquivo.
	*/
	public void exibeCodigoLinhas()
	{
		System.out.println("TOKENS DAS LINHAS DO ARQUIVO.ASM");
		for(int i=0;i<super.size();i++)
		{
			Linha linha=(Linha)super.get(i);
			linha.exibeCodigo();	
		}
	}

	/**
	* Exibe as informa��es completas das linhas do arquivo.
	*/
	public void exibeInfoLinhas()
	{
		System.out.println("INFORMA��ES DAS LINHAS DO ARQUIVO.ASM");
		for(int i=0;i<super.size();i++)
		{
			Linha linha=(Linha)super.get(i);
			linha.exibe();	
		}
	}
}