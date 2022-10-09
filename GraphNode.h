#pragma once
#include<iostream>
#include<string>
#include<vector>
enum GraphNodeType {
	Operator,
	Varible,
	NullType
};
class GraphNode {
public:
	GraphNode() {
		nodeType = NullType;
		nodeName = "";
		up.clear();
		down.clear();
	}
	GraphNodeType nodeType;
	std::string nodeName;
	std::vector<GraphNode*> up ;
	std::vector<GraphNode*> down ;
private:
};